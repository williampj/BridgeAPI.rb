# frozen_string_literal: true

class EventsController < ApplicationController
  # before_action :authorize_request

  def date_format(time)
    year = time.split('-')[0]
    month = time.split('-')[1]
    day = time.split('-')[2]
    "#{year}-#{month}-#{day}"
  end

  # Needs to find all events based on bridge_id or event_id
  # Needs to return id for each event as well
  def index
    # binding.pry
    if params[:event_id]
      event = Event.find(params[:event_id])
      events = Bridge.find(event.bridge_id).events
    elsif params[:bridge_id]
      events = Bridge.find(params[:bridge_id]).events
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
    event = Event.find(params[:id])
    render json: event, status: 200 # OK
  end

  # receives bridge id + data
  def create
    bridge = Bridge.find(event_params[:id])
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
      data: data,
      bridge_id: bridge.id,
      inbound_url: bridge.inbound_url,
      outbound_url: bridge.outbound_url
    )
    event.save! unless event_params[:test]
    EventWorker.new.perform(event, bridge, event_params[:test])

    render json: event, status: 201 # Created
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'a bridge by that id was not found' }, status: 400
  rescue ActiveRecord::RecordInvalid
    render json: { error: 'payload, bridge_id, or urls were invalid' }, status: 400 # Bad Request
  rescue ActiveRecord::NotNullViolation
    render json: { error: 'payload, bridge_id, or urls fields were not submitted' }, status: 400 # Bad Request
  end

  private

  def event_params
    params.permit(:id, :bridge_id, :event_id, :test, :inbound_url, :outbound_url)
  end
end

# Step 2
# payload:
# {
#   test: 'user entered string from editor',
#   production: 'user entered string from editor'
# }

# Step 3
#

# NB: Need to run `bundle exec sidekiq` in separate terminal
# localhost:3000/sidekiq to monitor sidekiq while running
# after turning it on
# => mount Sidekiq::Web => '/sidekiq

# events_data: {
#   inbound: {payload},
#   outbound: [ # 0 - 5
#     { request: {payload},
#       response: {payload}
#     },
#     { request: {payload},
#       response: {payload}
#     },
#     { request: {payload},
#       response: {payload}
#     },
#     { request: {payload},
#       response: {payload}
#     },
#     { request: {payload},
#       response: {payload}
#     }
#   ]

# }
