# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ContactController', type: :request do
  let(:payload) { contact_payload }

  it 'Delivers an email' do
    expect { ContactMailer.contact(payload).deliver_now }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'Responds with an empty body and 202 status code' do
    post contact_path, params: payload
    expect(response.status).to eql(202)
    expect(response.body).to eql('')
  end

  it 'returns status 422 unprocessable entity if no email filled out in the contact form' do
    payload['email'] = ''
    post contact_path, params: payload
    expect(response.status).to eql(422)
    expect(JSON.parse(response.body)).to eql({ 'error' => 'One or more fields were empty' })
  end

  it 'returns status 422 unprocessable entity if no subject filled out in the contact form' do
    payload['subject'] = ''
    post contact_path, params: payload
    expect(response.status).to eql(422)
    expect(JSON.parse(response.body)).to eql({ 'error' => 'One or more fields were empty' })
  end

  it 'returns status 422 unprocessable entity if no full_name filled out in the contact form' do
    payload['full_name'] = ''
    post contact_path, params: payload
    expect(response.status).to eql(422)
    expect(JSON.parse(response.body)).to eql({ 'error' => 'One or more fields were empty' })
  end

  it 'returns status 422 unprocessable entity if no message filled out in the contact form' do
    payload['message'] = ''
    post contact_path, params: payload
    expect(response.status).to eql(422)
    expect(JSON.parse(response.body)).to eql({ 'error' => 'One or more fields were empty' })
  end
end
