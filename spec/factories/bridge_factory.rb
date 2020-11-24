# frozen_string_literal: true

FactoryBot.define do
  factory :bridge do
    title { 'bridge_1' }
    outbound_url { 'myfakeoutbound.com' }
    inbound_url { 'myfakeinbound.com' }
    http_method { 'POST' }
    delay { 0 }
    retries { 0 }
    data do
      {
        payload: {
          first_name: 'Lee',
          last_name: 'Oswald',
          username: 'GrassyKnoll',
          email: 'kgb63@yandex.ru',
          top_level_key: '$payload.top_level_key',
          nested_key: {
            nested_key_two: '$payload.nested_key_1.nested_key_2'
          }
        }.to_json,
        test_payload: {
          "test_key_one": {
            "nested": 11
          },
          "test_key_two": 888
        }.to_json
      }
    end

    association :user

    trait :with_env do
      after(:create) do |bridge|
        create(:environment_variable, bridge_id: bridge.id)
      end
    end

    trait :with_header do
      after(:create) do |bridge|
        create(:header, bridge_id: bridge.id)
      end
    end
  end
end
