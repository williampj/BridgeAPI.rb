# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "demo#{String(rand).split('.')[1]}@demo.com" }
    password { 'password' }
  end
end
