# frozen_string_literal: true

require 'net/http'
require_relative '../lib/sidekiq/large_status_code'

class EventWorker
  include Sidekiq::Worker

  attr_writer :request_handler

  attr_accessor :retry_count

  def perform(event_id, _retries = 0)
    @event = Event.includes(:bridge).find(event_id)
    request_handler.execute
    event.complete!
  rescue StandardError => e
    request_handler.cleanup(e) unless e.instance_of? Sidekiq::LargeStatusCode

    return event.complete! if retry_count&.>= bridge.retries # TODO: Off by one?

    # TODO: We need filter error messages. ArgumentError and our stuff can be ignored but
    # should we really tell users "StandardError" if their service replied with 404?
    raise StandardError
  end

  private

  attr_reader :event

  def request_handler
    @request_handler ||= ::BridgeApi::Http::RequestHandler.new(event)
  end
end
