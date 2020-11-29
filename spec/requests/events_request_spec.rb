# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe 'EventsController', type: :request do
  before do
    @event = create(:event)
    @bridge = @event.bridge
    @user = @bridge.user
    @token = JsonWebToken.encode(user_id: @user.id)

    stub_request(:post, /.*/)
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: { data: 'stubbed response' }.to_json, headers: {})
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
    it 'creates a job' do
      headers = { 'CONTENT_TYPE' => 'application/json' }
      expect(EventWorker.jobs.count).to eq 0

      post "/events/#{@bridge.id}", params: '{ "data": { "hello": "world" } }', headers: headers

      expect(EventWorker.jobs.count).to eq 1
      expect(response).to have_http_status(202)
    end

    it 'returns 400 with invalid IDs' do
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/events/128371283', params: '{ "data": { "hello": "world" } }', headers: headers
      expect(response).to have_http_status(400)
    end
  end

  describe 'PATCH abort' do
    it 'all events with bridge_id' do
      event_ids = []
      headers = { 'CONTENT_TYPE' => 'application/json' }

      expect(EventWorker.jobs.count).to eq 0

      expect do
        post "/events/#{@bridge.id}",
             params: '{ "top_ledvel_key": "hello", "nested_key_1": { "nested_key_2": "world" } }',
             headers: headers
        event_ids.push(JSON.parse(response.body)['id'])
        post "/events/#{@bridge.id}",
             params: '{ "top_ledvel_key": "hello", "nested_key_1": { "nested_key_2": "world" } }',
             headers: headers
        event_ids.push(JSON.parse(response.body)['id'])
        post "/events/#{@bridge.id}",
             params: '{ "top_ledvel_key": "hello", "nested_key_1": { "nested_key_2": "world" } }',
             headers: headers
        event_ids.push(JSON.parse(response.body)['id'])
      end.to change(EventWorker.jobs, :count).by(3)

      expect(response).to have_http_status(202)
      expect do
        post "/events/abort?bridge_id=#{@bridge.id}", headers: authenticated_token
        EventWorker.drain
      end.to change(EventWorker.jobs, :count).by(-3)
      expect(event_ids.all? do |id|
        event = Event.find(id)
        event.aborted == true && event.completed == true
      end).to eq true
    end

    it 'an event with event_id' do
      event_id = nil
      headers = { 'CONTENT_TYPE' => 'application/json' }

      expect(EventWorker.jobs.count).to eq 0

      expect do
        post "/events/#{@bridge.id}",
             params: '{ "top_ledvel_key": "hello", "nested_key_1": { "nested_key_2": "world" } }',
             headers: headers
        event_id = JSON.parse(response.body)['id']
        post "/events/#{@bridge.id}",
             params: '{ "top_ledvel_key": "hello", "nested_key_1": { "nested_key_2": "world" } }',
             headers: headers
        post "/events/#{@bridge.id}",
             params: '{ "top_ledvel_key": "hello", "nested_key_1": { "nested_key_2": "world" } }',
             headers: headers
      end.to change(EventWorker.jobs, :count).by(3)

      expect(response).to have_http_status(202)
      expect do
        post "/events/abort?event_id=#{@event.id}", headers: authenticated_token
        expect { EventWorker.drain }.to raise_error StandardError
      end.to change(EventWorker.jobs, :count).by(-1)
      expect(@event.reload.completed).to eq true
      expect(@event.aborted).to eq true
    end
  end
end
