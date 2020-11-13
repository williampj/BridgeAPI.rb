# frozen_string_literal: true

require 'net/http'
require_relative '../lib/exceptions/large_status_code'
SCHEME = 'http://'

HTTP_ERRORS = [
  EOFError,
  Errno::ECONNRESET,
  Errno::EINVAL,
  Net::HTTPBadResponse,
  Net::HTTPHeaderSyntaxError,
  Net::ProtocolError,
  SocketError,
  Timeout::Error
].freeze

def make_http_uri(uri)
  return uri if uri.starts_with?('https')

  minus_scheme = uri.split('//').last
  "#{SCHEME}#{minus_scheme}"
end

def save_request(event, req)
  request = {
    payload: JSON.parse(req.body),
    date: DateTime.now.utc.to_s.split(' ').first,
    time: DateTime.now.utc.to_s.split(' ')[1],
    content_length: req.length
  }
  event_data = JSON.parse(event.data)
  event_data['outbound'].push({ 'request' => request, 'response' => {} })
  event.data = event_data.to_json
  event.save
end

def save_response(event, resp)
  response = {
    date: DateTime.now.utc.to_s.split(' ').first,
    time: DateTime.now.utc.to_s.split(' ')[1],
    status_code: resp.code,
    message: resp.message,
    size: resp.size,
    payload: resp.body
  }
  event_data = JSON.parse(event.data)
  event_data['outbound'].last['response'] = response
  event.data = event_data.to_json
  event.status_code = resp.code

  # if event.status_code < 300
  #   event.completed = true
  #   event.completed_at = Time.now.utc
  # end
  event.save
  raise Sidekiq::LargeStatusCode if event.status_code >= 300
end

class EventWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(event_id)
    event = Event.find(event_id)
    bridge = Bridge.find(event.bridge_id)
    method = bridge.method.capitalize

    EventWorker.sidekiq_options(retry: bridge.retries)

    # Generate and save request
    uri = URI(make_http_uri(bridge.outbound_url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    req = "Net::HTTP::#{method}".constantize.new(uri, 'Content-Type' => 'application/json')
    req.body = bridge.payload.to_json
    save_request(event, req)

    current_attempts = 0
    begin
      response = http.request(req)
      save_response(event, response)
    rescue StandardError => e
    rescue *HTTP_ERROS => e
    rescue Sidekiq::LargeStatusCode
      # RESCUE OTHER ERRORS
      current_attempts += 1
      if current_attempts > bridge.retries
        sleep bridge.delay * 60
        retry
      end
    end
    event.completed = true
    event.completed_at = Time.now.utc

    # retry_in do |_count, exception|
    #   case exception
    #   when *HTTP_ERRORS, Sidekiq::LargeStatusCode
    #     handles += 1
    #     bridge.delay
    #   end
    # end
    # rescue SocketError
    # binding.pry
    # attempts.times do
    #   sleep 5 if bridge.delay
    #   # sleep bridge.delay * 60 if bridge.delay
    #   response = http.request(req)
    #   save_response(event, response)
    #   break if event.completed
    # end

    # rescue *HTTP_ERRORS => e
    # binding.pry
    # rescue Errno::ECONNREFUSED => e
    # response = http.request(req)
    # save_response(event, response)
    # end
  end
end
