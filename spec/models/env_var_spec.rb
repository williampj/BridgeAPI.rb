require 'rails_helper'

RSpec.describe EnvironmentVariable, type: :model do
  it 'belongs to bridge' do
    bridge = Bridge.create(name: 'My First Bridge', payload: '', inbound_url: 'https://bridgeapi.dev/b1234/inbound', outbound_url: 'https://wowservice.io/new/23847923864', method: 'post', retries: 5, delay: 15)

    EnvironmentVariable1 = EnvironmentVariable.create(key: 'database', value: 'a102345ij2')
    EnvironmentVariable2 = EnvironmentVariable.create(key: 'database_password', value: 'supersecretpasswordwow')
    bridge.env_vars << EnvironmentVariable1
    bridge.env_vars << EnvironmentVariable2
    expect(EnvironmentVariable1.bridge).to eq bridge 
    expect(EnvironmentVariable2.bridge).to eq bridge 
  end
end
