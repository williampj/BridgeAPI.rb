# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  before(:context) do
    create_user
  end

  subject do
    create_event
  end

  it 'is valid as long as long as it has a valid bridge_id and data object' do
    event = Event.create({ bridge_id: subject.bridge_id, data: subject.data })
    expect(event).to be_valid
  end

  it 'is invalid without a data object' do
    subject.data = nil
    expect(subject).to_not be_valid
  end

  it 'belongs to a bridge' do
    expect(subject.bridge.class).to eql Bridge
  end

  it 'has its urls set to the url of the bridge it belongs to' do
    bridge = subject.bridge
    expect(bridge.inbound_url).to eql subject.inbound_url
    expect(bridge.outbound_url).to eql subject.outbound_url
  end

  it 'has a data attribute referencing a json object' do
    expect(JSON.parse(subject.data)).to be_an_instance_of(Hash)
  end

  it 'raises an error if data attribute does not reference a JSON object' do
    subject.data = 'not a json object'
    expect { subject.save! }.to raise_error('Validation failed: Data object must be a valid json object')
  end

  it 'does not accept removing inbound or outbound key from json data object' do
    data = JSON.parse(subject.data)
    data.delete('outbound')
    subject.data = data.to_json
    expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'does not accept removing payload, date, time, ip or content length from inbound key in json data object' do
    data = JSON.parse(subject.data)
    data['inbound'].delete('payload')
    subject.data = data.to_json
    expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'does not accept status codes above 599' do
    subject.status_code = 5555
    expect { subject.save! }.to raise_error('Validation failed: Status code must be less than or equal to 599')
  end

  it 'does not accept status codes below 100' do
    subject.status_code = 10
    expect { subject.save! }.to raise_error('Validation failed: Status code must be greater than or equal to 100')
  end

  pending '#inbound_payload returns the proper data'
end
