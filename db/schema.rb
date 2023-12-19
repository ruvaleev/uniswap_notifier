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

ActiveRecord::Schema[7.0].define(version: 2023_12_05_193042) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "portfolio_report_status", ["positions_fetching", "prices_fetching", "events_fetching", "results_analyzing", "completed", "failed"]
  create_enum "position_report_status", ["fees_info_fetching", "history_analyzing", "completed", "failed"]

  create_table "authentications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address", null: false
    t.datetime "last_usage_at"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_authentications_on_token"
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "notification_statuses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "uniswap_id", null: false
    t.datetime "last_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_sent_at"], name: "index_notification_statuses_on_last_sent_at"
    t.index ["uniswap_id", "user_id"], name: "index_notification_statuses_on_uniswap_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_notification_statuses_on_user_id"
  end

  create_table "portfolio_reports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "initial_message_id"
    t.integer "summary_message_id"
    t.jsonb "prices", default: {}, null: false
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", default: "positions_fetching", null: false, enum_type: "portfolio_report_status"
    t.index ["user_id"], name: "index_portfolio_reports_on_user_id"
  end

  create_table "position_reports", force: :cascade do |t|
    t.bigint "position_id", null: false
    t.integer "message_id"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", default: "fees_info_fetching", null: false, enum_type: "position_report_status"
    t.index ["position_id"], name: "index_position_reports_on_position_id"
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "portfolio_report_id", null: false
    t.integer "uniswap_id"
    t.integer "initial_tick"
    t.datetime "initial_timestamp", precision: nil
    t.string "owner"
    t.integer "tick_lower"
    t.integer "tick_upper"
    t.decimal "fee_growth_inside_last_x128_0"
    t.decimal "fee_growth_inside_last_x128_1"
    t.decimal "liquidity"
    t.decimal "hold_usd_value"
    t.jsonb "liquidity_changes", default: {}, null: false
    t.jsonb "collects", default: {}, null: false
    t.jsonb "liquidity_decreases", default: {}, null: false
    t.jsonb "liquidity_increases", default: {}, null: false
    t.jsonb "token_0", default: {}, null: false
    t.jsonb "token_1", default: {}, null: false
    t.jsonb "pool", default: {}, null: false
    t.jsonb "events", default: {}, null: false
    t.jsonb "fees_claims", default: {}, null: false
    t.index ["portfolio_report_id"], name: "index_positions_on_portfolio_report_id"
    t.index ["uniswap_id", "portfolio_report_id"], name: "index_positions_on_uniswap_id_and_portfolio_report_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.integer "telegram_chat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_wallets_on_address", unique: true
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "authentications", "users"
  add_foreign_key "notification_statuses", "users"
  add_foreign_key "portfolio_reports", "users"
  add_foreign_key "position_reports", "positions"
  add_foreign_key "positions", "portfolio_reports"
  add_foreign_key "wallets", "users"
end
