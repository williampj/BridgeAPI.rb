# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Header, type: :model do
  subject do
    Bridge.create(
      name: 'bridge',
      payload: '',
      inbound_url: Bridge.generate_inbound_url,
      outbound_url: "doggoapi.io/#{Bridge.generate_inbound_url}",
      method: 'POST',
      retries: 5,
      delay: 15
    )
  end

  # it 'belongs to bridge' do
  #   header1 = Header.create(
  #     key: 'X_API_KEY',
  #     value: 'ooosecrets',
  #     bridge: subject
  #   )
  #   header2 = Header.create(
  #     key: 'Authentication',
  #     value: 'Bearer 1oij2oubviu3498',
  #     bridge: subject
  #   )
  #   subject.headers << header1
  #   subject.headers << header2
  #   expect(header1.bridge).to eq subject
  #   expect(header2.bridge).to eq subject
  # end
end
