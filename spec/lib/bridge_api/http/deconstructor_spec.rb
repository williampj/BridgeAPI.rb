# frozen_string_literal: true

require_relative './spec_helper'

RSpec.describe BridgeApi::Http::Deconstructor do
  subject do
    bridge = create(:bridge, :with_header)
    BridgeApi::Http::Deconstructor.new bridge.headers
  end

  it 'can return filtered headers' do
    expect(subject.deconstruct('hello', 'world')).to eq 'FILTERED'
  end

  it 'can return the value when header doesn\'t exist' do
    expect(subject.deconstruct('hi', 'world')).to eq 'world'
  end
end
