# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EventsController', type: :request do
  before do
    @event = create(:event)
    @bridge = @event.bridge
    @user = @bridge.user
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  describe 'GET index' do
    it 'returns 200 with bridge_id' do
      get '/events', headers: authenticated_token, params: { bridge_id: @bridge.id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns 200 with event_id' do
      get '/events', headers: authenticated_token, params: { event_id: @event.id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns 400 with no params' do
      get '/events', headers: authenticated_token
      expect(response).to have_http_status(400)
    end

    it 'returns 400 with invalid IDs' do
      get '/events', headers: authenticated_token, params: { event_id: '128371283' }
      expect(response).to have_http_status(400)

      get '/events', headers: authenticated_token, params: { bridge_id: '128371283' }
      expect(response).to have_http_status(400)
    end

    it 'requires JWT' do
      get '/events', params: { event_id: @event.id }
      expect(response).to have_http_status(401)
    end
  end

  describe 'GET show' do
    it 'returns 200 with bridge_id' do
      get "/events/#{@event.id}", headers: authenticated_token, params: { event_id: @event.id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns 400 with invalid IDs' do
      get '/events/128371283', headers: authenticated_token, params: { event_id: '128371283' }
      expect(response).to have_http_status(400)

      get '/events/128371283', headers: authenticated_token, params: { bridge_id: '128371283' }
      expect(response).to have_http_status(400)
    end

    it 'requires JWT' do
      get "/events/#{@event.id}", params: { event_id: @event.id }
      expect(response).to have_http_status(401)
    end
  end

  describe 'POST destroy' do
    it 'returns 204' do
      delete "/events/#{@event.id}", headers: authenticated_token, params: { event_id: @event.id }
      expect(response).to have_http_status(204)
    end

    it 'returns 400 with invalid IDs' do
      delete '/events/128371283', headers: authenticated_token, params: { event_id: '128371283' }
      expect(response).to have_http_status(400)

      delete '/events/128371283', headers: authenticated_token, params: { bridge_id: '128371283' }
      expect(response).to have_http_status(400)
    end

    it 'requires JWT' do
      delete "/events/#{@event.id}", params: { event_id: @event.id }
      expect(response).to have_http_status(401)
    end
  end

  describe 'POST create' do
    pending 'creates a job'
    pending 'returns 400 with invalid IDs'
  end
end
