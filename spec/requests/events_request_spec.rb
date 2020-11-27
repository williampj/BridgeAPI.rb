# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe 'EventsController', type: :request do
  let(:event) { create :event }

  before do
    @bridge = event.bridge
    @user = @bridge.user
    @token = JsonWebToken.encode(user_id: @user.id)

    stub_request(:post, /.*/)
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: { data: 'stubbed response' }.to_json, headers: {})
  end

  describe 'PATCH abort' do
    it 'aborts all ongoing events' do
      # worker = EventWorker.new
      # req_handler = ::BridgeApi::Http::RequestHandler.new event
      # req_handler.formatter = MockFailFormatter.new
      # worker.request_handler = req_handler

      # event2 = create :event
      # event3 = create :event
      # byebug

      # expect do
      #   worker.perform event.id
      #   # worker.perform event2.id
      #   # worker.perform event3.id
      # end.to raise_error StandardError
      # byebug

      # expect(EventWorker.jobs.count).to eq 3
      worker = EventWorker.new
      req_handler = ::BridgeApi::Http::RequestHandler.new event
      req_handler.formatter = MockFailFormatter.new
      worker.request_handler = req_handler
  
      expect do
        worker.perform event.id
      end.to raise_error StandardError
  
      expect(EventWorker.jobs.count).to eq 1
    end
  end

  describe 'GET index' do
    it 'returns 200 with bridge_id' do
      get '/events', headers: authenticated_token, params: { bridge_id: @bridge.id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns 200 with event_id' do
      get '/events', headers: authenticated_token, params: { event_id: event.id }
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
      get '/events', params: { event_id: event.id }
      expect(response).to have_http_status(401)
    end
  end

  describe 'GET show' do
    it 'returns 200 with bridge_id' do
      get "/events/#{event.id}", headers: authenticated_token, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns 400 with invalid IDs' do
      get '/events/128371283', headers: authenticated_token, params: { event_id: '128371283' }
      expect(response).to have_http_status(400)

      get '/events/128371283', headers: authenticated_token, params: { bridge_id: '128371283' }
      expect(response).to have_http_status(400)
    end

    it 'requires JWT' do
      get "/events/#{event.id}", params: { event_id: event.id }
      expect(response).to have_http_status(401)
    end
  end

  describe 'POST destroy' do
    it 'returns 204' do
      delete "/events/#{event.id}", headers: authenticated_token, params: { event_id: event.id }
      expect(response).to have_http_status(204)
    end

    it 'returns 400 with invalid IDs' do
      delete '/events/128371283', headers: authenticated_token, params: { event_id: '128371283' }
      expect(response).to have_http_status(400)

      delete '/events/128371283', headers: authenticated_token, params: { bridge_id: '128371283' }
      expect(response).to have_http_status(400)
    end

    it 'requires JWT' do
      delete "/events/#{event.id}", params: { event_id: event.id }
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
end
