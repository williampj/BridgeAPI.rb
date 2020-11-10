<<<<<<< HEAD
class EventsController < ApplicationController
  before_action :authorize_request
  # Needs to find all events based on bridge_id or event_id
  # Needs to return id for each event as well
  def index
    binding.pry
    events = @current_user.Event.all
    binding.pry
    events.map do |event|
      updated_at = String(event.updated_at)
      date = date_format(updated_at.split(' ')[1])
      time = updated_at.split(' ')[0]

      { time: time,
        date: date,
        status_code: event.status_code }
    end
    binding.pry
  end

  def show; end

  private

  def date_format(_date)
    year = time.split('-')[0]
    month = time.split('-')[1]
    day = time.split('-')[2]
    "#{year}-#{month}-#{day}"
  end
end

# SCHEMA
# create_table "events", force: :cascade do |t|
#   t.boolean "completed", null: false
#   t.binary "data", null: false
#   t.string "inbound_url", null: false
#   t.string "outbound_url", null: false
#   t.integer "status_code", null: false
#   t.datetime "completed_at"
#   t.bigint "bridge_id", null: false
#   t.datetime "created_at", precision: 6, null: false
#   t.datetime "updated_at", precision: 6, null: false
#   t.index ["bridge_id"], name: "index_events_on_bridge_id"
# end
=======
# frozen_string_literal: true

class EventsController < ApplicationController
end
>>>>>>> 11d80c27fa5104bb4322e4fb4e3883f0e02bcfa1
