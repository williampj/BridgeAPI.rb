# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnvironmentVariable, type: :model do
  before do
    create_user
  end

  subject do
    create_bridge
  end

  after do
    @user.destroy!
  end

  it 'belongs to bridge' do
    environment_variable1 = EnvironmentVariable.new(key: 'database', value: 'a102345ij2', bridge: subject)
    environment_variable2 = EnvironmentVariable.new(
      key: 'database_password',
      value: 'supersecretpasswordwow',
      bridge: subject
    )
    expect(environment_variable1.bridge).to eq subject
    expect(environment_variable2.bridge).to eq subject
  end

  it 'encrypts value before save' do
    password = 'supersecretpassword'
    subject.save!
    environment_variable = EnvironmentVariable.create(key: 'database', value: password, bridge: subject)
    expect(environment_variable.value).to_not eq password
  end
end
