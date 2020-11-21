# frozen_string_literal: true

require_relative './spec_helper'

RSpec.describe BridgeApi::SyntaxParser::HeadersParser do
  before do
    stub_request(:post, 'http://example.com/some_path?query=string')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: { data: 'stubbed response' }.to_json, headers: {})
  end

  subject do
    BridgeApi::Http::Formatter.new MockDeconstructor.new
  end

  it 'can format a successful request' do
    event = create(:event)
    uri = URI('http://example.com/some_path?query=string')

    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Post.new uri
      request.body = { data: 'hello world' }.to_json
      response = http.request request # Net::HTTPResponse object
      subject.format! event, request, response
    end

    data = JSON.parse(event.data)

    expect(data.keys).to eq %w[inbound outbound]
    expect(data['outbound'].first.keys).to eq %w[request response]
    expect(data['outbound'].first['request'].keys).to eq %w[payload dateTime contentLength uri headers]
    expect(data['outbound'].first['response'].keys).to eq %w[dateTime statusCode message size payload]
    expect(data['outbound'].first['request']['payload']).to be_truthy
    expect(data['outbound'].first['response']['payload']).to be_truthy
    expect(data['outbound'].first['response']['statusCode']).to eq '200'
    expect(data['outbound'].first['request']['uri']).to eq 'http://example.com/some_path?query=string'
  end

  it 'can format a failed request' do
    event = create(:event)
    uri = URI('http://example2.com/some_path?query=string')

    Net::HTTP.start(uri.host, uri.port) do |_http|
      request = Net::HTTP::Post.new uri
      request.body = { data: 'hello world' }.to_json
      raise StandardError
    rescue StandardError => e
      subject.format_error! event, request, e
    end

    data = JSON.parse(event.data)

    expect(data.keys).to eq %w[inbound outbound]
    expect(data['outbound'].first.keys).to eq %w[request response]
    expect(data['outbound'].first['request'].keys).to eq %w[payload dateTime contentLength uri headers]
    expect(data['outbound'].first['response'].keys).to eq %w[message]
    expect(data['outbound'].first['request']['payload']).to be_truthy
    expect(data['outbound'].first['request']['uri']).to eq 'http://example2.com/some_path?query=string'
    expect(data['outbound'].first['response']).to eq({ 'message' => 'StandardError' })
  end
end
