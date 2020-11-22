# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :set_event, only: %i[show destroy]

  def index
    if fetch_events.empty?
      render json: { error: 'invalid parameters' }, status: 400 # Bad Request
    else
      render json: { events: @events }, status: 200
    end
  end

  def show
    if @event
      render json: { event: @event }, status: 200
    else
      render json: { error: 'an event by that id was not found' }, status: 400
    end
  end

  def destroy
    return render json: {}, status: 204 if @event&.destroy

    render json: { error: 'an event by that id was not found' }, status: 400
  end

  def create
    event = create_event_object(create_data_object, find_bridge)
    if event.save
      EventWorker.perform_async(event.id)
      render json: {}, status: 202 # Accepted
    else
      render json: { error: 'Invalid parameters' }, status: 400 # Bad Request
    end
  end

  private

  def event_params
    params.permit(:id, :bridge_id, :event_id, :test)
  end

  def fetch_events
    @events = if event_params[:bridge_id]
                Event.where(bridge_id: event_params[:bridge_id]).order(completed_at: :desc).limit(100)
              elsif event_params[:event_id]
                Event.where(bridge_id: find_event&.bridge_id).order(completed_at: :desc).limit(100)
              else
                []
              end
  end

  def create_data_object
    {
      'inbound' => {
        'payload' => JSON.parse(request.body.read),
        'dateTime' => DateTime.now.utc,
        'ip' => request.ip,
        'contentLength' => request.content_length
      },
      'outbound' => []
    }
  end

  def create_event_object(data, bridge)
    Event.new(
      data: data.to_json,
      bridge_id: bridge&.id,
      test: event_params[:test] || false
    )
  end

  def set_event
    @event = find_event
  end

  def find_event
    Event.find_by(id: event_params[:event_id])
  end

  def find_bridge
    Bridge.find_by(id: event_params[:bridge_id])
  end
end
