# frozen_string_literal: true

require 'net/http'
require_relative '../lib/exceptions/large_status_code'

class EventWorker
  include Sidekiq::Worker
  attr_accessor :retry_count

  sidekiq_retry_in { 5 } # TODO: SET RETRY_IN DYNAMICALLY

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

  def perform(event_id)
    event = Event.find(event_id)
    bridge = Bridge.find(event.bridge_id)
    execute_request_response_cycle(event, bridge)
    save_event(event)
  rescue *HTTP_ERRORS, Sidekiq::LargeStatusCode => e
    save_http_error(event, e) if HTTP_ERRORS.include?(e.class)
    save_event(event) && return if retry_count&.>= bridge.retries

    raise 'Error or high status code' # activates sidekiq retry
  end

  private

  def set_headers(req, bridge)
    bridge.headers.each { |header| req[header['key']] = header['value'] }
  end

  def save_event(event)
    event.completed = true
    event.completed_at = Time.now.utc
    event.save!
  end

  def create_error_response(error)
    {
      message: error.message
    }
  end

  def save_http_error(event, error)
    response = create_error_response(error)
    event_data = JSON.parse(event.data)

    event_data['outbound'].last['response'] = response
    event.data = event_data.to_json
    event.save
  end

  def create_response_object(payload, response)
    {
      dateTime: DateTime.now.utc,
      statusCode: response.code,
      message: response.message,
      size: response.size,
      payload: payload
    }
  end

  def save_response(event, resp)
    resp_code = resp.code.to_i
    payload = (resp_code >= 300 ? {} : JSON.parse(resp.body))
    response = create_response_object(payload, resp)
    event_data = JSON.parse(event.data)

    event_data['outbound'].last['response'] = response
    event.data = event_data.to_json
    event.save
    raise Sidekiq::LargeStatusCode if resp_code >= 300
  end

  def create_request_object(payload, length)
    {
      payload: payload,
      dateTime: DateTime.now.utc,
      contentLength: length
    }
  end

  def save_request(event, length, payload)
    request = create_request_object(payload, length)
    event_data = JSON.parse(event.data)

    event_data['outbound'].push({ 'request' => request, 'response' => {} })
    event.data = event_data.to_json
    event.save
  end

  def prepend_scheme(uri)
    return uri if uri.starts_with?('https')

    minus_scheme = uri.split('//').last
    "#{SCHEME}#{minus_scheme}"
  end

  def generate_http_request(bridge, payload)
    method = bridge.method.capitalize
    uri = URI(prepend_scheme(bridge.outbound_url))
    http = Net::HTTP.new(uri.host, uri.port)
    req = "Net::HTTP::#{method}".constantize.new(uri, 'Content-Type' => 'application/json')

    http.use_ssl = (uri.scheme == 'https')
    set_headers(req, bridge)
    req.body = payload.to_json
    [http, req]
  end

  def extract_payload(bridge, event)
    if event.test
      JSON.parse(bridge.data['test_payload'])
    else
      JSON.parse(bridge.data['payload'])
    end
  end

  def execute_request_response_cycle(event, bridge)
    payload = extract_payload(bridge, event)
    http, req = generate_http_request(bridge, payload)

    save_request(event, req.length, payload)
    response = http.request(req)
    save_response(event, response)
  end
end
