# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  def authenticated_token
    { 'BRIDGE-JWT': @token }
  end

  def parse_response(response)
    JSON.parse(response.body)
  end

  def create_valid_user
    @current_user = User.create(email: 'emailexample@mail.com', password: 'secret')
    @token = JsonWebToken.encode(user_id: @current_user.id)
  end

  before(:context) do
    create_valid_user
  end

  after(:context) do
    @current_user.destroy!
  end

  it 'show action returns the requested user when passed a valid token' do
    get '/user', headers: authenticated_token

    expect(response).to have_http_status 200
  end

  it 'show action returns status 401 when not receiving valid token' do
    get '/user'

    expect(response).to have_http_status 401
  end

  it 'create action creates a new user and returns json object (with user and token) and 201 status code' do
    post '/user', params: { user: { email: 'someone@somewhere.com', password: 'notsecret' } }
    body = parse_response(response)

    expect(response.content_type).to eql('application/json; charset=utf-8')
    expect(response).to have_http_status 201
    expect(body['token']).to be_truthy
    expect(body['user']).to include('email')
  end

  it 'create action returns 422 status
  and error message ("email or password is invalid")
  with invalid email at creation' do
    post '/user', params: { user: { email: 'bademail', password: 'notsecret' } }
    body = parse_response(response)

    expect(body['error']).to eql('email or password is invalid')
    expect(response).to have_http_status 422
  end

  it 'create action returns 422 status
  and error message ("email or password is invalid")
  with invalid password at creation' do
    post '/user', params: { user: { email: 'somemail@mail.com', password: '' } }
    body = parse_response(response)

    expect(body['error']).to eql('email or password is invalid')
    expect(response).to have_http_status 422
  end

  it 'create action returns 422 status
  and error message ("email or password is invalid")
  with invalid password at creation' do
    post '/user', params: { user: { email: 'somemail@mail.com', password: '' } }
    body = parse_response(response)

    expect(body['error']).to eql('email or password is invalid')
    expect(response).to have_http_status 422
  end

  it 'destroy action deletes the user and returns empty body and 204 status' do
    delete '/user', headers: authenticated_token

    expect(response).to have_http_status 204
    expect(response.body).to be_empty

    # Subsequent request for now deleted user gives 404 status
    get '/user', headers: headers
    expect(response).to have_http_status 401
    create_valid_user
  end

  it 'update action returns updated user and 200 status if valid email update' do
    params = { user: { email: 'newandimproved@mail.com' } }
    put '/user', params: params, headers: authenticated_token
    body = parse_response(response)

    expect(response).to have_http_status 200
    expect(body['email']).to eql('newandimproved@mail.com')
  end

  it 'update action returns updated user and 200 status if valid password update' do
    params = { user: { password: 'extrasuperdupersecure' } }
    put '/user', params: params, headers: authenticated_token

    expect(response).to have_http_status 200
  end
end
