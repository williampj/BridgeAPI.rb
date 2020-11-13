# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bridge, type: :model do
  before do
    create_user
  end

  after do
    @current_user.destroy!
  end

  subject do
    create_bridge
  end

  it 'is valid when passed valid info' do
    expect(subject).to be_valid
  end

  it 'is invalid without a title' do
    subject.title = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid without an outbound_url' do
    subject.outbound_url = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid without a method' do
    subject.method = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid without a retries property' do
    subject.retries = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid without a delay' do
    subject.delay = nil
    expect(subject).to_not be_valid
  end

  it 'is valid without a data property' do
    subject.data = nil
    expect(subject).to be_valid
  end

  it 'is not valid when data has more than two keys' do
    subject.data['test'] = 1
    expect(subject).to_not be_valid
  end

  it 'is not valid when payload is not a hash' do
    subject.data['payload'] = 1
    expect(subject).to_not be_valid
  end

  it 'is not valid when test payload is not a hash' do
    subject.data['test_payload'] = 1
    expect(subject).to_not be_valid
  end

  it 'automatically sets the inbound url when created' do
    expect(subject.inbound_url).to be_nil
    expect(subject).to be_valid
    subject.save!
    expect(subject.inbound_url).to_not be_nil
  end

  it 'only sets inbound_url on create' do
    expect(subject.inbound_url).to be_nil
    expect(subject).to be_valid
    subject.save!
    expect(subject.inbound_url).to_not be_nil
    url = subject.inbound_url
    subject.save!
    expect(url).to eq subject.inbound_url
  end
end
