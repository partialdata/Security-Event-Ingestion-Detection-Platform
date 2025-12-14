# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_01_01_002000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "api_token_digest", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["api_token_digest"], name: "index_agents_on_api_token_digest", unique: true
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.string "dedup_key", null: false
    t.bigint "event_id", null: false
    t.string "reason", null: false
    t.string "severity", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_alerts_on_agent_id"
    t.index ["dedup_key"], name: "index_alerts_on_dedup_key"
    t.index ["event_id"], name: "index_alerts_on_event_id"
    t.index ["severity"], name: "index_alerts_on_severity"
    t.index ["status"], name: "index_alerts_on_status"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.string "host", null: false
    t.datetime "occurred_at", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_events_on_agent_id"
    t.index ["event_type"], name: "index_events_on_event_type"
    t.index ["host"], name: "index_events_on_host"
    t.index ["occurred_at"], name: "index_events_on_occurred_at"
  end

  add_foreign_key "alerts", "agents"
  add_foreign_key "alerts", "events"
  add_foreign_key "events", "agents"
end
