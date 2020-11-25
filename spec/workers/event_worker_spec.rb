# frozen_string_literal: true

require_relative './spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe EventWorker, type: :worker do
  # it 'Event jobs are enqueued in the scheduled queue' do
  #   described_class.perform_async
  #   assert_equal :scheduled, described_class.queue
  # end

  # it 'goes into the jobs array for testing environment' do
  #   expect do
  #     described_class.perform_async
  #   end.to change(described_class.jobs, :size).by(1)
  # end

  before do
    @event = create :event
    @bridge = @event.bridge

    stub_request(:post, 'https://myfakeoutbound.com/')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: { data: 'stubbed response' }.to_json, headers: {})
  end

  it 'can process an event' do
    expect(Event.find(@event.id).completed).to eq false

    EventWorker.new.perform @event.id

    expect(Event.find(@event.id).completed).to eq true
  end

  pending 'can retry 3 times'
  
  pending 'can clean up when errors are raised'
end
