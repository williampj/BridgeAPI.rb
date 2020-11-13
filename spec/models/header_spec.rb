# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Header, type: :model do
  before do
    create_user
  end

  subject do
    create_bridge
  end

  it 'belongs to bridge' do
    header1 = Header.create(
      key: 'X_API_KEY',
      value: 'ooosecrets',
      bridge: subject
    )
    header2 = Header.create(
      key: 'Authentication',
      value: 'Bearer 1oij2oubviu3498',
      bridge: subject
    )
    subject.headers << header1
    subject.headers << header2
    expect(header1.bridge).to eq subject
    expect(header2.bridge).to eq subject
  end
end
