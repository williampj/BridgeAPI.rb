# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnvironmentVariable, type: :model do
  subject do
    create_bridge
  end

  it 'belongs to bridge' do
    environment_variable1 = EnvironmentVariable.create(key: 'database', value: 'a102345ij2')
    environment_variable2 = EnvironmentVariable.create(key: 'database_password', value: 'supersecretpasswordwow')
    subject.environment_variables << environment_variable1
    subject.environment_variables << environment_variable2
    expect(environment_variable1.bridge).to eq subject
    expect(environment_variable2.bridge).to eq subject
  end
end
