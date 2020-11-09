require 'rails_helper'

RSpec.describe Event, type: :model do
  it 'belongs to bridge' do
    bridge = Bridge.create(name: 'My First Bridge', payload: '', inbound_url: 'https://bridgeapi.dev/b1234/inbound', outbound_url: 'https://wowservice.io/new/23847923864', method: 'post', retries: 5, delay: 15)

    event1 = Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: bridge.inbound_url, data: '', status_code: 300)
    event2 = Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: bridge.inbound_url, data: '', status_code: 300)
    bridge.events << event1
    bridge.events << event2
    expect(event1.bridge).to eq bridge 
    expect(event2.bridge).to eq bridge 
  end
end
