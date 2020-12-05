# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :set_event, only: %i[show destroy]

  def index
    if fetch_events.empty?
      render json: { error: 'invalid parameters' }, status: 400 # Bad Request
    else
      render json: { events: @events.to_json(only: %i[completed completed_at id status_code]) }, status: 200
    end
  end

  def show
    if @event
      render json: {
        event: @event,
        bridge_title: @event.bridge.title,
        events: fetch_events.to_json(only: %i[completed completed_at id status_code])
      }, status: 200
    else
      render json: { error: 'an event by that id was not found' }, status: 400
    end
  end

  def destroy
    return render json: {}, status: 204 if @event&.destroy

    render json: { error: 'an event by that id was not found' }, status: 400
  end

  def create
    event = create_event(find_bridge)
    if event.save
      EventWorker.perform_in(event.bridge.delay.minutes, event.id)
      render json: { id: event.id }, status: 202 # Accepted
    else
      render json: { error: 'Invalid parameters' }, status: 400 # Bad Request
    end
  rescue JSON::ParserError
    render json: { error: 'Invalid request. Payload must be in JSON' }, status: 400 # Bad Request
  end

  # Aborts a single going event if query param `event_id` is found, otherwise, if `bridge_id` is present,
  # it aborts all ongoing events with that `bridge_id`. Returns 400 bad request if not event is found.
  def abort
    events = events_to_abort
    return render_message status: 400 if events.empty? # Bad Request

    events.update aborted: true, completed: true, completed_at: Time.now.utc
    render_message
  end

  private

  def event_params
    params.permit(:id, :bridge_id, :event_id, :test)
  end

  def events_to_abort
    if event_params[:bridge_id]
      Event.includes(:bridge)
           .where(bridge_id: event_params[:bridge_id], "bridges.user_id": @current_user.id, completed: false)
    else
      Event.includes(:bridge)
           .where(id: event_params[:event_id], "bridges.user_id": @current_user.id, completed: false)
    end
  end

  def fetch_events
    @events = Event.includes(:bridge)
                   .where(
                     bridge_id: event_params[:bridge_id] || find_event&.bridge_id,
                     "bridges.user_id": @current_user.id
                   ).references(:bridge)
                   .order(completed_at: :desc)
                   .limit(100)
  end

  def data
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

  def create_event(bridge)
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
    Event.includes(:bridge)
         .where(
           id: event_params[:id] || event_params[:event_id],
           "bridges.user_id": @current_user.id
         ).first
  end

  def find_bridge
    Bridge.find_by(id: event_params[:bridge_id])
  end
end
