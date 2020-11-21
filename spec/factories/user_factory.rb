# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'demo@demo.com' }
    password { 'password' }
  end
end
