# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bridge, type: :model do
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

  it 'has many env vars' do
    subject.env_vars << EnvironmentVariable.create(
      key: 'database',
      value: 'a102345ij2'
    )
    subject.env_vars << EnvironmentVariable.create(
      key: 'database_password',
      value: 'supersecretpasswordwow'
    )

    expect(subject.env_vars.count).to eq 2
  end

  it 'has many headers' do
    subject.headers << Header.create(
      key: 'X_API_KEY',
      value: 'ooosecrets'
    )
    subject.headers << Header.create(
      key: 'Authentication',
      value: 'Bearer 1oij2oubviu3498'
    )

    expect(subject.headers.count).to eq 2
  end

  it 'has many events' do
    5.times do
      subject.events << Event.create(
        completed: false,
        outbound_url: subject.outbound_url,
        inbound_url: subject.inbound_url,
        data: '',
        status_code: 300
      )
    end

    expect(subject.events.count).to eq 5
  end
end
