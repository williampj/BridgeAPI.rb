# frozen_string_literal: true

require_relative './spec_helper'

RSpec.describe BridgeApi::Http::Deconstructor do
  before do
    stub_request(:post, 'http://example.com/some_path?query=string')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: { data: 'stubbed response' }.to_json, headers: {})
  end
  subject do
    bridge = create(:bridge, :with_header)
    BridgeApi::Http::Deconstructor.new bridge.headers
  end
end
