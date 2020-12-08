# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ContactController', type: :request do
  before do
    @payload = contact_payload
  end

  it 'Responds with an empty body and 202 status code' do
    post contact_path, params: @payload
    expect(response.status).to eql(202)
    expect(response.body).to eql('')
  end

  it 'Delivers an email' do
    expect { ContactMailer.contact(@payload).deliver_now }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
