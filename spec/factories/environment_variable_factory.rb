# frozen_string_literal: true

FactoryBot.define do
  factory :environment_variable do
    key { 'API_KEY' }
    value { 'hello world' }
  end
end
