# frozen_string_literal: true

require 'net/http'

class EventWorker
  include Sidekiq::Worker

  def make_http_uri(uri)
    uri =~ %r{\Ahttp://} ? uri : "http://#{uri}"
  end

  def perform(event_id)
    event = Event.find(event_id)
    bridge = Bridge.find(event.bridge_id)
    method = bridge.method.capitalize

    uri = URI(make_http_uri(bridge.outbound_url))
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = "Net::HTTP::#{method}".constantize.new(uri, 'Content-Type' => 'application/json')
    request.body = bridge.payload.to_json

    response = http.request(req)
    response_body = JSON.parse(response.body)

    # payload = {
    #   test: {},
    #   production: {}
    # }

    render json: { payload: response_body }, status: 201 # Created
  end
end
