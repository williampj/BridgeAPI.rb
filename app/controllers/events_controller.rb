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
    bridge = Bridge.find(event_params[:bridge_id])
    data = create_data_object
    event = create_event_object(data, bridge)

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

  def date_format(time)
    year = time.split('-')[0]
    month = time.split('-')[1]
    day = time.split('-')[2]
    "#{year}-#{month}-#{day}"
  end

  def create_data_object
    { 'inbound' => {
      'payload' => JSON.parse(request.body.read),
      'date' => DateTime.now.utc.to_s.split(' ').first,
      'time' => DateTime.now.utc.to_s.split(' ')[1],
      'ip' => request.ip,
      'content_length' => request.content_length
    },
      'outbound' => [] }
  end

  def create_event_object(data, bridge)
    Event.new(
      data: data.to_json,
      bridge_id: bridge.id,
      test: event_params[:test] || false,
      inbound_url: bridge.inbound_url,
      outbound_url: bridge.outbound_url
    )
  end

  def create_sidebar_events(events)
    events.map do |event|
      updated_at = String(event.updated_at)
      time = date_format(updated_at.split(' ')[1])
      date = updated_at.split(' ')[0]
      { id: event.id,
        time: time.slice(0..-3),
        date: date,
        status_code: event.status_code }
    end
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
end
