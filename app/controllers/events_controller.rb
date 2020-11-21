# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :set_events, only: :index
  before_action :set_event, only: %i[show destroy]

  def index
    render json: { events: @events }, status: 200
  rescue ActiveRecord::RecordInvalid
    render json: { error: 'neither event_id nor bridge_id were valid' }, status: 400 # Bad Request
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'events matching that id were not found' }, status: 400
  rescue ActiveRecord::NotNullViolation
    render json: { error: 'neither event_id nor bridge_id were not submitted' }, status: 400 # Bad Request
  end

  def show
    render json: @event, status: 200
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'an event by that id was not found' }, status: 400
  end

  def destroy
    @event.destroy
  end

  def create
    event = create_event_object(create_data_object, find_bridge)
    event.save!
    EventWorker.perform_async(event.id)
    render json: {}, status: 202 # Accepted (asynchronous processing)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'a bridge by that id was not found' }, status: 400
  rescue ActiveRecord::RecordInvalid
    render json: { error: 'payload, bridge_id, or urls were invalid' }, status: 400 # Bad Request
  rescue ActiveRecord::NotNullViolation
    render json: { error: 'payload, bridge_id, or urls fields were not submitted' }, status: 400 # Bad Request
  end

  private

  def event_params
    params.permit(:id, :bridge_id, :event_id, :test)
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
      bridge_id: bridge.id,
      test: event_params[:test] || false
    )
  end

  def set_events
    @events = if event_params[:bridge_id]
                Event.where(bridge_id: event_params[:bridge_id]).order(completed_at: :desc).limit(100)
              elsif event_params[:event_id]
                Event.where(bridge_id: find_event.bridge_id).order(completed_at: :desc).limit(100)
              else
                raise ActiveRecord::NotNullViolation
              end
  end

  def set_event
    @event = find_event
  end

  def find_event
    Event.find(event_params[:event_id])
  end

  def find_bridge
    Bridge.find(event_params[:bridge_id])
  end
end
