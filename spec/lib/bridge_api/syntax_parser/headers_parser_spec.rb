# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BridgeApi::SyntaxParser::HeadersParser do
  it 'can parse envs' do
    bridge = create(:bridge, :with_env, :with_header)
    parser = BridgeApi::SyntaxParser::HeadersParser.new(bridge.environment_variables)
    data = {}

    parser.parse(bridge.headers) do |k, v|
      data[k] = v
    end

    expect(data).to eq({ 'hello' => 'hello world' })
  end

  it 'will raise InvalidEnvironmentVariable when no key exists' do
    bridge = create(:bridge, :with_header)
    parser = BridgeApi::SyntaxParser::HeadersParser.new(bridge.environment_variables)
    data = {}

    expect do
      parser.parse(bridge.headers) do |k, v|
        data[k] = v
      end
    end.to raise_error InvalidEnvironmentVariable
  end
end
