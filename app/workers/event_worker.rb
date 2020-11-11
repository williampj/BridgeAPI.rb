# frozen_string_literal: true

class EventWorker
  include Sidekiq::Worker

  # takes event id argument
  # find event =>
  # find bridge =>
  # git payload & outbound url
  # => send it

  def perform(event_id)
    # do something
  end
end
