# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bridge, type: :model do
  before do
    create_user
  end

  subject do
    create_bridge
  end

  it 'add event info returns the proper information' do
    event = create :event
    event.completed = true
    event.completed_at = DateTime.now.utc
    subject.save!
    subject.events << event
    subject_with_event_info = subject.add_event_info

    expect(subject_with_event_info['eventCount']).to eq 1
    expect(subject_with_event_info['completedAt']).to eq event.completed_at
    expect(subject_with_event_info['eventId']).to eq event.id
    expect(subject_with_event_info['latestRequest']).to eq event.created_at
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
    subject.http_method = nil
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

  it 'slug cannot be updated after creation (fails silently)' do
    subject.save
    slug = subject.slug # 'b53b9c093a75df827ca08a7f5a52bc86'
    new_slug = 'fb056cbaa877ac498e351f4db4ed8081'

    subject.update(slug: new_slug)
    expect(Bridge.exists?(slug: slug)).to eql(true)
    expect(Bridge.exists?(slug: new_slug)).to eql(false)
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
