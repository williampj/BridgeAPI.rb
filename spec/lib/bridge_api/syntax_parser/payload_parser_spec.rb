# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BridgeApi::SyntaxParser::PayloadParser do
  subject do
    bridge = create(:bridge, :with_env)
    BridgeApi::SyntaxParser::PayloadParser.new(bridge.environment_variables)
  end

  it 'can parse envs' do
    expect(
      subject.parse(
        Net::HTTP.new(URI('example.com')),
        { data: '$env.API_KEY' }
      )
    ).to eq({ data: 'hello world' })
  end

  it 'will raise InvalidEnvironmentVariable when no key exists' do
    expect do
      subject.parse(
        Net::HTTP.new(URI('example.com')),
        { data: '$env.api_key' }
      )
    end.to raise_error InvalidEnvironmentVariable
  end

  it 'can access payload data wtih symbols' do
    expect(
      subject.parse(
        { data: 'hello world' },
        { data: '$payload.data' }
      )
    ).to eq({ data: 'hello world' })
  end

  it 'can access payload data wtih strings' do
    expect(
      subject.parse(
        { 'data' => 'hello world' },
        { 'data' => '$payload.data' }
      )
    ).to eq({ 'data' => 'hello world' })
  end

  it 'can access deeply nested objects' do
    expect(
      subject.parse(
        {
          'data' => 'hello world',
          'nested_data' => {
            'nested_data_1' => [
              {
                'nested_data_2' => 'hello world2'
              }
            ]
          }
        },
        {
          'data' => {
            'nested_key' => '$payload.data',
            'nested_array' => [
              {
                'one' => '$payload.nested_data.nested_data_1'
              },
              {
                'two' => '$payload.nested_data.nested_data_1'
              }
            ]
          }
        }
      )
    ).to eq(
      {
        'data' => {
          'nested_array' => [
            {
              'one' => [
                {
                  'nested_data_2' => 'hello world2'
                }
              ]
            },
            {
              'two' => [
                {
                  'nested_data_2' => 'hello world2'
                }
              ]
            }
          ],
          'nested_key' => 'hello world'
        }
      }
    )
  end
end
