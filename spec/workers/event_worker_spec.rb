# frozen_string_literal: true

require_relative './spec_helper'

RSpec.describe EventWorker, type: :worker do
  let(:event) { create :event }
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
    stub_request(:post, 'https://myfakeoutbound.com/')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: { data: 'stubbed response' }.to_json, headers: {})
  end

  it 'can process an event' do
    expect(event.completed).to eq false

    EventWorker.new.perform event.id

    expect(event.reload.completed).to eq true
  end

  it 'can retry when errors are raised' do
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

    data = JSON.parse(event.data)

    expect(data['outbound'].first['response']).to eq({ 'message' => 'StandardError' })
    expect(data['outbound'].first.keys).to eq %w[request response]
    expect(data['outbound'].first['request'].keys).to eq %w[payload dateTime contentLength uri headers]
    expect(data['outbound'].first['response'].keys).to eq %w[message]
    expect(data['outbound'].first['request']['payload']).to be_truthy
    expect(data['outbound'].first['response']['payload']).to be_nil
    expect(data['outbound'].first['response']['statusCode']).to be_nil
    expect(data['outbound'].first['request']['uri']).to eq 'https://myfakeoutbound.com'
  end
end
