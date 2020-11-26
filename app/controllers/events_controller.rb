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
      render json: {}, status: 202 # Accepted
    else
      render json: { error: 'Invalid parameters' }, status: 400 # Bad Request
    end
  rescue JSON::ParserError
    render json: { error: 'Invalid request. Payload must be in JSON' }, status: 400 # Bad Request
  end

  def abort
    retries = Sidekiq::RetrySet.new.select

    retries.each do |job|
      id = JSON.parse(job.value)['args'].first
      remove_job job if job_selected id
    end
  end

  private

  def remove_job(job)
    id = JSON.parse(job.value)['args'].first
    event = Event.find id

    event.update completed: true
    job.delete
  end

  def job_selected(id)
    (id == params[:id]&.to_i) || params[:id].nil?
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
