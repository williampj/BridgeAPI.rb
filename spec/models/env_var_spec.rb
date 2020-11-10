# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnvironmentVariable, type: :model do
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
    environment_variable1 = EnvironmentVariable.create(key: 'database', value: 'a102345ij2')
    environment_variable2 = EnvironmentVariable.create(key: 'database_password', value: 'supersecretpasswordwow')
    subject.env_vars << environment_variable1
    subject.env_vars << environment_variable2
    expect(environment_variable1.bridge).to eq subject
    expect(environment_variable2.bridge).to eq subject
  end
end
