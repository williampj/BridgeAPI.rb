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
    event_response = @event.data['outbound'].last['response']
    event_response['payload'] = JSON.parse(response.body)
    # #=> {"ip" => "153.33.111.24"}
    event_response['message'] = response.message
    # #=> "OK"
    event_response['status_code'] = @event.status_code = response.code
    # #=> "200"

    if @event.status_code < 300
      @event.completed = true
      @event.completed_at = Time.now.utc
    end
    @event.save
  end

  def make_http_uri(uri)
    return uri if uri.starts_with?('https')

    minus_scheme = uri.split('//').last
    "#{SCHEME}#{minus_scheme}"
  end

  def perform(event_id)
    @event = Event.find(event_id)
    bridge = Bridge.find(@event.bridge_id)
    method = bridge.method.capitalize

    uri = URI(make_http_uri(bridge.outbound_url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    req = "Net::HTTP::#{method}".constantize.new(uri, 'Content-Type' => 'application/json')
    request_body = bridge.payload # HOW TO DYNAMICALLY GENERATE THIS?
    req.body = request_body.to_json
    save_request(request_body, req.body.length)

    response = http.request(req)
    save_response(response)

    # binding.pry

    # payload = {
    #   test: {},
    #   production: {}
    # }
  end
end
