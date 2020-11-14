# frozen_string_literal: true

def date_format(time)
  year = time.split('-')[0]
  month = time.split('-')[1]
  day = time.split('-')[2]
  "#{year}-#{month}-#{day}"
end

class EventsController < ApplicationController
  # before_action :authorize_request

  def index
    if event_params[:event_id]
      event = Event.find(event_params[:event_id])
      events = Bridge.find(event.bridge_id).events
    elsif event_params[:bridge_id]
      events = Bridge.find(event_params[:bridge_id]).events
    else raise ActiveRecord::RecordNotFound
    end

    safe_events = events.map do |event|
      updated_at = String(event.updated_at)
      time = date_format(updated_at.split(' ')[1])
      date = updated_at.split(' ')[0]
      { id: event.id,
        time: time.slice(0..-3),
        date: date,
        status_code: event.status_code }
    end
    render json: safe_events, status: 200 # OK
  end

  def show
    event = Event.find(event_params[:id])
    render json: event, status: 200 # OK
  end

  def destroy
    event = Event.find(event_params[:id])
    event.destroy
  end

  def create
    bridge = Bridge.find(create_event_params[:id])
    test_mode = create_event_params[:test]
    payload = JSON.parse(request.body.read)
    data = { 'inbound' => {
      'payload' => payload,
      'date' => DateTime.now.utc.to_s.split(' ').first,
      'time' => DateTime.now.utc.to_s.split(' ')[1],
      'ip' => request.ip,
      'content_length' => request.content_length
    },
             'outbound' => [] }
    event = Event.new(
      data: data.to_json,
      bridge_id: bridge.id,
      test: test_mode,
      inbound_url: bridge.inbound_url,
      outbound_url: bridge.outbound_url
    )
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

  def create_event_params
    params.require(:bridge).permit(:id, :test)
  end

  def event_params
    params.permit(:id, :bridge_id, :event_id, :test)
  end
end
