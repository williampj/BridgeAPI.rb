# frozen_string_literal: true

class MockRequestHandler
  attr_reader :event, :bridge

  def initialize(event)
    @event = event
    @bridge = event.bridge
  end
end
