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
    event = create_event(find_bridge)
    if event.save
      EventWorker.perform_async(event.id)
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
    events = if bridge_id_present
               Event.includes(:bridge)
                    .where(bridge_id: event_params[:bridge_id], "bridges.user_id": @current_user.id, completed: false)
             else
               Event.includes(:bridge)
                    .where(id: event_params[:event_id], "bridges.user_id": @current_user.id, completed: false)
             end

    render_message status: 400 unless events # Bad Request

    events.update aborted: true, completed: true

    render_message
  end

  private

  def bridge_id_present
    !!event_params[:bridge_id]
  end

  def event_params
    params.permit(:id, :bridge_id, :event_id, :test)
  end

  def find_by_bridge_id
    Event.includes(:bridge)
         .where(bridge_id: event_params[:bridge_id], "bridges.user_id": @current_user.id)
         .references(:bridge)
         .order(completed_at: :desc)
         .limit(100)
  end

  def find_without_bridge_id
    Event.includes(:bridge)
         .where(bridge_id: find_event&.bridge_id, "bridges.user_id": @current_user.id)
         .references(:bridge)
         .order(completed_at: :desc)
         .limit(100)
  end

  def fetch_events
    @events = if event_params[:bridge_id]
                find_by_bridge_id
              elsif event_params[:event_id]
                find_without_bridge_id
              else
                [] # Prevent nil
              end
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
    Event.includes(:bridge).where(id: event_params[:id] || event_params[:event_id], "bridges.user_id": @current_user.id).first
  end

  def find_bridge
    Bridge.find_by(id: event_params[:bridge_id])
  end
end
