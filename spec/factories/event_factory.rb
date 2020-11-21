# frozen_string_literal: true

# TODO?
FactoryBot.define do
  factory :event do
    before(:create) do
      create(:bridge)
    end

    completed { false }
    inbound_url { 'myfakeinbound.com' }
    outbound_url { 'myfakeoutbound.com' }
  end
end
