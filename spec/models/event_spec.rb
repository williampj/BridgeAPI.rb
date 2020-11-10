# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
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

  it 'belongs to bridge' do
    event1 = Event.create(
      completed: false,
      outbound_url: subject.outbound_url,
      inbound_url: subject.inbound_url,
      data: '',
      status_code: 300
    )
    event2 = Event.create(
      completed: false,
      outbound_url: subject.outbound_url,
      inbound_url: subject.inbound_url,
      data: '',
      status_code: 300
    )

    subject.events << event1
    subject.events << event2
    expect(event1.bridge).to eq subject
    expect(event2.bridge).to eq subject
  end
end
