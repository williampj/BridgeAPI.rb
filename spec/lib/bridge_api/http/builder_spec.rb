# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BridgeApi::Http::Builder do
  before do
  end

  after do
  end

  subject do
    create(:bridge, :with_env)
  end

  it 'is valid when passed valid info' do
    expect(subject).to be_valid
  end
end
