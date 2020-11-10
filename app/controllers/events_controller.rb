class EventsController < ApplicationController 
  def index 

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