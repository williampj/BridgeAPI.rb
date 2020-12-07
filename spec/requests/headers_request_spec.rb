# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Headers', type: :request do
  before do
    create_user
    @bridge = create_bridge
  end

  after do
    @user.destroy!
  end

  subject do
    Header.new(key: 'test key', value: 'a1234566', bridge: @bridge)
  end

  describe 'handles all requests properly:' do
    it 'destroys headers' do
      subject.save!

      delete header_path(subject.id), headers: authenticated_token

      expect(response).to be_successful
    end

    it 'doesnt destroy other\'s headers' do
      create_other_user
      other_bridge = create_bridge
      other_bridge.title = 'other\s bridge'
      other_bridge.user = @other_user
      other_bridge.save!
      header = Header.create(key: 'other\'s header', value: 'a9393939393', bridge: other_bridge)

      delete header_path(header.id), headers: authenticated_token

      expect(response).to_not be_successful

      @other_user.destroy!
    end
  end
end
