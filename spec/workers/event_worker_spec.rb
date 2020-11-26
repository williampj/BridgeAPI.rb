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
    @bridge = Bridge.find event.bridge.id

    stub_request(:post, 'https://myfakeoutbound.com/')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: { data: 'stubbed response' }.to_json, headers: {})
  end

  context 'Event worker' do
    let(:event) { create :event }

    it 'can process an event' do
      expect(event.reload.completed).to eq false

      EventWorker.new.perform event.id

      expect(event.reload.completed).to eq true
    end

    it 'can retry 3 times' do
      worker = EventWorker.new
      req_handler = ::BridgeApi::Http::RequestHandler.new event
      req_handler.formatter = MockFailFormatter.new
      worker.request_handler = req_handler

      expect do
        worker.perform event.id
      end.to raise_error StandardError

      expect(EventWorker.jobs.count).to eq 1
      # TODO: - Need to fix retry_count bug
    end

    it 'can clean up when errors are raised' do
      worker = EventWorker.new
      req_handler = ::BridgeApi::Http::RequestHandler.new event
      req_handler.formatter = MockFailFormatter.new
      worker.request_handler = req_handler

      expect do
        worker.perform event.id
      end.to raise_error StandardError
      expect(JSON.parse(event.reload.data)['outbound'][0]['response']).to eq({ 'message' => 'StandardError' })
    end
  end
end
