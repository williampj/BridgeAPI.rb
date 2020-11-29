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

  def abort
    events = if bridge_id_present
               Event.includes(:bridge).where(bridge_id: event_params[:bridge_id], "bridges.user_id": @current_user.id)
             else
               Event.includes(:bridge).where(id: event_params[:event_id], "bridges.user_id": @current_user.id)
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

  def fetch_events
    @events = if event_params[:bridge_id]
                Event.where(bridge_id: event_params[:bridge_id]).order(completed_at: :desc).limit(100)
              elsif event_params[:event_id]
                Event.where(bridge_id: find_event&.bridge_id).order(completed_at: :desc).limit(100)
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
    Event.find_by(id: event_params[:event_id])
  end

  def find_bridge
    Bridge.find_by(id: event_params[:bridge_id])
  end
end
