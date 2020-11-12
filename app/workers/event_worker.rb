# frozen_string_literal: true

require 'net/http'
SCHEME = 'http://'

class EventWorker
  include Sidekiq::Worker

  def save_request(request_body, content_length)
    request = {
      'payload' => request_body,
      'date' => DateTime.now.utc.to_s.split(' ').first,
      'time' => DateTime.now.utc.to_s.split(' ')[1],
      'content_length' => content_length
    }
    @event.data['outbound'].push({ 'request' => request, 'response' => {} })
  end

  def save_response(response)
    response_object = {
      'date' => DateTime.now.utc.to_s.split(' ').first,
      'time' => DateTime.now.utc.to_s.split(' ')[1],
      'status_code' => response.code,
      'message' => response.message,
      'size' => response.size,
      'payload' => JSON.parse(response.body)
    }
    @event.data['outbound'].last['response'] = response_object
    @event.status_code = response.code

    if @event.status_code < 300
      @event.completed = true
      @event.completed_at = Time.now.utc
    end
    @event.save unless @test
  end

  def make_http_uri(uri)
    return uri if uri.starts_with?('https')

    minus_scheme = uri.split('//').last
    "#{SCHEME}#{minus_scheme}"
  end

  def perform(event, bridge, test = false)
    @test = test
    @event = event
    # bridge = Bridge.find(@event.bridge_id)
    method = bridge.method.capitalize

    uri = URI(make_http_uri(bridge.outbound_url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    req = "Net::HTTP::#{method}".constantize.new(uri, 'Content-Type' => 'application/json')
    request_body = bridge.payload # Done on the frontend / bridge controller?
    req.body = request_body.to_json
    save_request(request_body, req.body.length)

    response = http.request(req)
    save_response(response)

    # Send back test event from here?

    # payload = {
    #   test: {},
    #   production: {}
    # }
  end
end
