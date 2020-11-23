# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bridges', type: :request do
  before do
    create_user
  end

  after do
    @current_user.destroy!
  end

  subject do
    create_bridge
  end

  describe 'handles all requests properly:' do
    it 'handles index method with valid user' do
      subject.title = 'index method bridge'
      subject.save!
      get bridges_path, headers: authenticated_token
      expect(response).to be_successful
      expect(response.body).to include subject.title
    end

    it 'doesn\'t return another user\'s bridge using index' do
      subject.title = 'index method bridge'
      subject.save!

      create_other_user
      other_bridge = create_bridge
      other_bridge.title = 'other\s bridge'
      other_bridge.user = @other_user
      other_bridge.save!

      get bridges_path, headers: authenticated_token
      expect(response).to be_successful
      expect(response.body).to_not include other_bridge.title
      expect(response.body).to include subject.title

      @other_user.destroy!
    end

    it 'handles the show method successfully' do
      subject.title = 'show method bridge'
      subject.save!
      get bridge_path(subject.id), headers: authenticated_token
      expect(response.body).to include 'show method bridge'
    end

    it 'doesn\'t return another user\'s bridge using show' do
      create_other_user
      other_bridge = create_bridge
      other_bridge.title = 'other\s bridge'
      other_bridge.user = @other_user
      other_bridge.save!

      get bridge_path(other_bridge.id), headers: authenticated_token

      expect(response).to_not be_successful

      @other_user.destroy!
    end

    it 'destroys bridges' do
      subject.save!

      delete bridge_path(subject.id), headers: authenticated_token

      expect(response).to be_successful
    end

    it 'doesnt destroy other\'s bridges' do
      create_other_user
      other_bridge = create_bridge
      other_bridge.title = 'other\s bridge'
      other_bridge.user = @other_user
      other_bridge.save!

      delete bridge_path(other_bridge.id), headers: authenticated_token

      expect(response).to_not be_successful
    end

    it 'creates bridges without headers or environment variables' do
      post bridges_path, params: { bridge: bridge_hash }, headers: authenticated_token
      bridge = Bridge.find(JSON.parse(response.body)['id'])

      expect(response).to be_successful
      expect(bridge).to be_truthy
      expect(bridge.headers.count).to eq 0
      expect(bridge.environment_variables.count).to be 0
    end

    it 'creates bridges with headers and environment variables' do
      creation_hash = bridge_hash
      creation_hash[:headers_attributes] = [{ key: 'my first key', value: 'my first value' }]
      creation_hash[:environment_variables_attributes] = [{ key: 'my second key', value: 'my second value' }]

      post bridges_path, params: { bridge: creation_hash }, headers: authenticated_token
      bridge = Bridge.find(JSON.parse(response.body)['id'])

      expect(response).to be_successful
      expect(bridge).to be_truthy
      expect(bridge.headers.count).to eq 1
      expect(bridge.environment_variables.count).to be 1
    end

    it 'doesnt create bridge without title' do
      invalid_hash = bridge_hash
      invalid_hash[:title] = nil

      post bridges_path, params: { bridge: invalid_hash }, headers: authenticated_token

      expect(response).to_not be_successful
    end
    it 'doesnt create bridge without outbound_url' do
      invalid_hash = bridge_hash
      invalid_hash[:outbound_url] = nil

      post bridges_path, params: { bridge: invalid_hash }, headers: authenticated_token

      expect(response).to_not be_successful
    end
    it 'creates bridge without data' do
      invalid_hash = bridge_hash
      invalid_hash[:data] = nil

      post bridges_path, params: { bridge: invalid_hash }, headers: authenticated_token

      expect(response).to be_successful
    end
    it 'doesnt create bridge without method' do
      invalid_hash = bridge_hash
      invalid_hash[:http_method] = nil

      post bridges_path, params: { bridge: invalid_hash }, headers: authenticated_token

      expect(response).to_not be_successful
    end
    it 'doesnt create bridge without delay' do
      invalid_hash = bridge_hash
      invalid_hash[:delay] = nil

      post bridges_path, params: { bridge: invalid_hash }, headers: authenticated_token

      expect(response).to_not be_successful
    end
    it 'doesnt create bridge without retries' do
      invalid_hash = bridge_hash
      invalid_hash[:retries] = nil

      post bridges_path, params: { bridge: invalid_hash }, headers: authenticated_token

      expect(response).to_not be_successful
    end

    it 'updates bridges' do
      subject.save!

      patch bridge_path(subject.id), params: { bridge: { title: 'updated bridge ' } }, headers: authenticated_token

      expect(response).to be_successful
    end

    it 'doesnt update other\'s bridges' do
      create_other_user
      other_bridge = create_bridge
      other_bridge.title = 'other\s bridge'
      other_bridge.user = @other_user
      other_bridge.save!

      patch bridge_path(other_bridge.id), params: { bridge: { title: 'updated bridge ' } }, headers: authenticated_token

      expect(response).to_not be_successful
    end
  end
end
