# frozen_string_literal: true

require_relative './spec_helper'

RSpec.describe BridgeApi::Http::Builder do
  subject do
    event = create(:event)
    BridgeApi::Http::Builder.new(
      MockRequestHandler.new(event),
      MockPayloadParser.new,
      MockHeadersParser.new
    )
  end

  it 'can generate http objects' do
    http, req = subject.generate

    expect(http.use_ssl?).to be true
    expect(http.port).to eq 443

    expect(req['Content-Type']).to eq 'application/json'
    expect(req['header_1']).to eq 'value_1'
    expect(req['header_2']).to eq 'value_2'
    expect(req.uri.to_s).to eq 'https://myfakeoutbound.com'
    expect(req.body).to eq '{"data":"hello world"}'
  end
end
