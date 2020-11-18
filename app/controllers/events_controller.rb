# frozen_string_literal: true

class EventsController < ApplicationController
  # before_action :authorize_request

  def index
    events = retrieve_events
    sidebar_events = create_sidebar_events(events)

    render json: sidebar_events, status: 200
  rescue ActiveRecord::RecordInvalid
    render json: { error: 'neither event_id nor bridge_id were valid' }, status: 400 # Bad Request
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'events matching that id were not found' }, status: 400
  rescue ActiveRecord::NotNullViolation
    render json: { error: 'neither event_id nor bridge_id were not submitted' }, status: 400 # Bad Request
  end

  def show
    event = Event.find(event_params[:id])
    render json: event, status: 200
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'an event by that id was not found' }, status: 400
  end

  def destroy
    event = Event.find(event_params[:id])
    event.destroy
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
    datetime = DateTime.now.utc.to_s.split(' ')
    { 'inbound' => {
      'payload' => JSON.parse(request.body.read),
      'date' => datetime.first,
      'time' => datetime[1],
      'ip' => request.ip,
      'content_length' => request.content_length
    },
      'outbound' => [] }
  end

  def create_event_object(data, bridge)
    Event.new(
      data: data.to_json,
      bridge_id: bridge.id,
      test: event_params[:test] || false
    )
  end

  def create_sidebar_events(events)
    events.map(&:sidebar_format).sort_by { |event| event[:id] }.reverse
  end

  def retrieve_events
    if event_params[:bridge_id]
      Bridge.find(event_params[:bridge_id]).events
    elsif event_params[:event_id]
      Event.find(event_params[:event_id]).bridge.events
    else
      raise ActiveRecord::NotNullViolation
    end
  end

  def find_bridge
    Bridge.find(event_params[:bridge_id])
  end
end
