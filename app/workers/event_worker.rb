# frozen_string_literal: true

require 'net/http'
require_relative '../lib/exceptions/large_status_code'

SCHEME = 'http://'

HTTP_ERRORS = [
  Net::HTTPBadResponse,
  Net::HTTPHeaderSyntaxError,
  Net::ProtocolError,
  EOFError,
  Errno::ECONNRESET,
  Errno::EINVAL,
  SocketError,
  Timeout::Error
].freeze

def make_http_uri(uri)
  return uri if uri.starts_with?('https')

  minus_scheme = uri.split('//').last
  "#{SCHEME}#{minus_scheme}"
end

def save_request(event, length, payload)
  request = {
    payload: JSON.parse(payload),
    date: DateTime.now.utc.to_s.split(' ').first,
    time: DateTime.now.utc.to_s.split(' ')[1],
    content_length: length
  }
  event_data = JSON.parse(event.data)
  event_data['outbound'].push({ 'request' => request, 'response' => {} })
  event.data = event_data.to_json
  event.save
end

def save_response(event, resp)
  resp_code = resp.code.to_i
  payload = (resp_code >= 300 ? {} : JSON.parse(resp.body))
  response = {
    date: DateTime.now.utc.to_s.split(' ').first,
    time: DateTime.now.utc.to_s.split(' ')[1],
    status_code: resp.code,
    message: resp.message,
    size: resp.size,
    payload: payload 
  }
  event_data = JSON.parse(event.data)
  event_data['outbound'].last['response'] = response
  event.data = event_data.to_json

  event.status_code = resp_code
  event.save
  raise Sidekiq::LargeStatusCode if resp_code >= 300
end

def save_http_error(event, error)
  response = {
    date: '',
    time: '',
    status_code: '',
    message: error.message,
    size: '',
    payload: {}
  }

  event_data = JSON.parse(event.data)
  event_data['outbound'].last['response'] = response
  event.data = event_data.to_json
  event.save
end

class EventWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(event_id)
    event = Event.find(event_id)
    bridge = Bridge.find(event.bridge_id)
    method = bridge.method.capitalize
    retries = bridge.retries
    current_attempts = 0

    # Generate request
    uri = URI(make_http_uri(bridge.outbound_url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    req = "Net::HTTP::#{method}".constantize.new(uri, 'Content-Type' => 'application/json')
    req.body = bridge.payload.to_json
    
    begin
      current_attempts += 1
      save_request(event, req.length, bridge.payload)
      response = http.request(req)
      save_response(event, response)
    rescue *HTTP_ERRORS, Sidekiq::LargeStatusCode => e
      save_http_error(event, e) if HTTP_ERRORS.include?(e.class)
      if current_attempts <= bridge.retries
        sleep 1 # DEVELOPMENT 
        # sleep bridge.delay * 60 # PRODUCTION
        retry
      end
    end

    event.completed = true
    event.completed_at = Time.now.utc
    event.save
  end
end
