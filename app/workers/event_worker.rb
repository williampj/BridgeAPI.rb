# frozen_string_literal: true

require 'net/http'
require_relative '../lib/exceptions/large_status_code'

class EventWorker
  include Sidekiq::Worker
  attr_accessor :retry_count

  def perform(event_id, _retries = 0)
    event = Event.includes(:bridge).find(event_id)
    request_handler = ::BridgeApi::Http::Handler.new(event)
    request_handler.execute
    event.complete!
    # rescue StandardError => e
    #   request_handler.cleanup(e) unless e.instance_of? Sidekiq::LargeStatusCode

    #   return event.complete! if retry_count&.>= bridge.retries # TODO: Off by one?

    #   raise StandardError
  end
end
