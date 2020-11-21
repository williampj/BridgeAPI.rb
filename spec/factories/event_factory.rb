# frozen_string_literal: true

# TODO?
FactoryBot.define do
  factory :event do
    association :bridge

    completed { false }
    inbound_url { 'myfakeinbound.com' }
    outbound_url { 'myfakeoutbound.com' }
    data do
      {
        'inbound' => {
          'payload' => {
            'bridge_id' => '1',
            'top_level_key' => 'present',
            'nested_key_1' => {
              'nested_key_2' => 'present'
            }
          },
          'dateTime' => '2020-11-21T13:59:47.349Z',
          'ip' => '0.0.0.0',
          'contentLength' => 101
        },
        'outbound' => []
      }.to_json
    end

    trait :completed do
      # TODO
    end
  end
end
