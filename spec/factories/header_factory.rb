# frozen_string_literal: true

FactoryBot.define do
  factory :header do
    key { 'hello' }
    value { '$env.API_KEY' }
  end
end
