# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EnvironmentVariables', type: :request do
  before do
    create_user
    @bridge = create_bridge
  end

  after do
    @user.destroy!
  end

  subject do
    EnvironmentVariable.new(key: 'test key', value: 'a1234566', bridge: @bridge)
  end

  describe 'handles all requests properly:' do
    it 'destroys environment variables' do
      subject.save!

      delete environment_variable_path(subject.id), headers: authenticated_token

      expect(response).to be_successful
    end

    it 'doesnt destroy other\'s environment variables' do
      create_other_user
      other_bridge = create_bridge
      other_bridge.title = 'other\s bridge'
      other_bridge.user = @other_user
      other_bridge.save!
      environment_variable = EnvironmentVariable.create(
        key: 'other\'s environment variable',
        value: 'a9393939393',
        bridge: other_bridge
      )

      delete environment_variable_path(environment_variable.id), headers: authenticated_token

      expect(response).to_not be_successful

      @other_user.destroy!
    end
  end
end
