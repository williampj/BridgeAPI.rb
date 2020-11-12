# frozen_string_literal: true

class EventsController < ApplicationController
  # before_action :authorize_request

  # Needs to find all events based on bridge_id or event_id
  # Needs to return id for each event as well
  def index
    #   events = @current_user.bridges
    #   events.map! do |event|
    #     updated_at = String(event.updated_at)
    #     date = date_format(updated_at.split(' ')[1])
    #     time = updated_at.split(' ')[0]
    #     { id: 1,
    #       time: time,
    #       date: date,
    #       status_code: event.status_code }
    #   end
    #   render json: { events: events }, status: 200 # OK
  end

  def show; end

  # receive bridge id + data
  def create
    bridge = Bridge.find(event_params[:id])
    payload = JSON.parse(request.body.read)
    data = { inbound: payload, outbound: [] }
    event = Event.new(
      data: data,
      bridge_id: bridge.id,
      inbound_url: bridge.inbound_url,
      outbound_url: bridge.outbound_url
    )
    event.save!
    EventWorker.new.perform(event.id)
    # render json: {}, status: 201 # Created
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'a bridge by that id was not found' }, status: 400
  rescue ActiveRecord::RecordInvalid
    render json: { error: 'payload, bridge_id, or urls were invalid' }, status: 400 # Bad Request
  rescue ActiveRecord::NotNullViolation
    render json: { error: 'payload, bridge_id, or urls fields were not submitted' }, status: 400 # Bad Request
  end

  private

  def date_format(_date)
    year = time.split('-')[0]
    month = time.split('-')[1]
    day = time.split('-')[2]
    "#{year}-#{month}-#{day}"
  end

  def event_params
    params.require(:bridge).permit(:id, :inbound_url, :outbound_url)
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
