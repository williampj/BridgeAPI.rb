# frozen_string_literal: true

require_relative './spec_helper'

RSpec.describe BridgeApi::Http::Deconstructor do
  before do
    stub_request(:post, 'https://myfakeoutbound.com:80/')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: { data: 'stubbed response' }.to_json, headers: {})

    stub_request(:post, 'https://myfakeoutbound2.com:80/')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 300, body: { data: 'stubbed response' }.to_json, headers: {})
  end

  subject do
    event = create(:event)
    handler = BridgeApi::Http::RequestHandler.new event
    handler.http_builder = MockSuccessBuilder.new
    handler.formatter = MockFormatter.new
    handler
  end

  it 'can execute' do
    subject.execute
  end

  it 'can cleanup' do
    subject.cleanup(StandardError)
  end

  it 'raises an error for non-200 status codes' do
    subject.http_builder = MockFailBuilder.new
    expect do
      subject.execute
    end.to raise_error Sidekiq::LargeStatusCode
  end
end
