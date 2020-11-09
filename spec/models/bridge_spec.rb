require 'rails_helper'

RSpec.describe Bridge, type: :model do
  it 'saves' do
    bridge = Bridge.create(name: 'My First Bridge', payload: '', inbound_url: 'https://bridgeapi.dev/b1234/inbound', outbound_url: 'https://wowservice.io/new/23847923864', method: 'post', retries: 5, delay: 15)
    expect(Bridge.first).to eq bridge
  end

  it 'has many env vars' do 
    bridge = Bridge.create(name: 'My First Bridge', payload: '', inbound_url: 'https://bridgeapi.dev/b1234/inbound', outbound_url: 'https://wowservice.io/new/23847923864', method: 'post', retries: 5, delay: 15)

    bridge.env_vars << EnvironmentVariable.create(key: 'database', value: 'a102345ij2')
    bridge.env_vars << EnvironmentVariable.create(key: 'database_password', value: 'supersecretpasswordwow')

    expect(bridge.env_vars.count).to eq 2
  end

  it 'has many headers' do 
    bridge = Bridge.create(name: 'My First Bridge', payload: '', inbound_url: 'https://bridgeapi.dev/b1234/inbound', outbound_url: 'https://wowservice.io/new/23847923864', method: 'post', retries: 5, delay: 15)

    bridge.headers << Header.create(key: 'X_API_KEY', value: 'ooosecrets')
    bridge.headers << Header.create(key: 'Authentication', value: 'Bearer 1oij2oubviu3498')

    expect(bridge.headers.count).to eq 2
  end

  it 'has many events' do 
    bridge = Bridge.create(name: 'My First Bridge', payload: '', inbound_url: 'https://bridgeapi.dev/b1234/inbound', outbound_url: 'https://wowservice.io/new/23847923864', method: 'post', retries: 5, delay: 15)

    bridge.events << Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: bridge.inbound_url, data: '', status_code: 300)
    bridge.events << Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: bridge.inbound_url, data: '', status_code: 300)
    bridge.events << Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: bridge.inbound_url, data: '', status_code: 300)
    bridge.events << Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: bridge.inbound_url, data: '', status_code: 300)
    bridge.events << Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: bridge.inbound_url, data: '', status_code: 300)

    expect(bridge.events.count).to eq 5
  end
end
