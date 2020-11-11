# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authorize_request
  before_action :set_user
  # Needs to find all events based on bridge_id or event_id
  # Needs to return id for each event as well
  # def index
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
  # end

  def show; end

  # receive bridge id + data
  def create
    bridge = Bridge.find(params[:id])
    data = { inbound: request.body, outbounds: [] }
    event = Event.new(data: data, bridge_id: bridge.id)
    if event.save
      # EventWorker.perform(id of event just created)
      status 201 # Created
    else
      status 400 # Bad Request
    end
  end

  private

  def date_format(_date)
    year = time.split('-')[0]
    month = time.split('-')[1]
    day = time.split('-')[2]
    "#{year}-#{month}-#{day}"
  end

  def set_user
    # bridge_id or #event_id
    # => User
  end
end

# Step 1
# Convert binary to jsonb

# Step 2
# payload:
{
  test: 'user entered string from editor',
  production: 'user entered string from editor'
}

# Step 3
#

# NB: Need to run `bundle exec sidekiq` in separate terminal
# localhost:3000/sidekiq to monitor sidekiq while running
# after turning it on
# => mount Sidekiq::Web => '/sidekiq
