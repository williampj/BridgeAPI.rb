# frozen_string_literal: true

require 'net/http'
require_relative '../lib/sidekiq/large_status_code'

class EventWorker
  include Sidekiq::Worker

  attr_writer :request_handler

  attr_accessor :retry_count

  def perform(event_id)
    @event = Event.includes(:bridge).find(event_id)
    return if @event.aborted

    execute_request
  rescue StandardError => e
    # We can skip clean up on error `Sidekiq::LargeStatusCode` because we did
    # recieve a response and it was saved properly.
    request_handler.cleanup(e) unless e.instance_of? Sidekiq::LargeStatusCode

    return event.complete! if retry_count&.>= @event.bridge.retries

    event.save

    # TODO: We need filter error messages. ArgumentError and our stuff can be ignored but
    # should we really tell users "StandardError" if their service replied with 404?
    raise StandardError
  end

  private

  attr_reader :event

  def execute_request
    request_handler.execute
    event.complete!
  end

  def request_handler
    @request_handler ||= ::BridgeApi::Http::RequestHandler.new(event)
  end
end
