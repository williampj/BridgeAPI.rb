# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_09_184334) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bridges", force: :cascade do |t|
    t.string "name", null: false
    t.string "inbound_url", null: false
    t.string "outbound_url", null: false
    t.string "method", null: false
    t.integer "retries", null: false
    t.integer "delay", null: false
    t.binary "payload", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["inbound_url"], name: "index_bridges_on_inbound_url", unique: true
  end

  create_table "environment_variables", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.bigint "bridge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bridge_id"], name: "index_environment_variables_on_bridge_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "completed", null: false
    t.binary "data", null: false
    t.string "inbound_url", null: false
    t.string "outbound_url", null: false
    t.integer "status_code", null: false
    t.datetime "completed_at"
    t.bigint "bridge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bridge_id"], name: "index_events_on_bridge_id"
  end

  create_table "headers", force: :cascade do |t|
    t.string "value", null: false
    t.string "key", null: false
    t.bigint "bridge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bridge_id"], name: "index_headers_on_bridge_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_hash", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
