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

ActiveRecord::Schema[7.0].define(version: 2023_11_28_135550) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "positions", force: :cascade do |t|
    t.integer "uniswap_id"
    t.integer "initial_tick"
    t.datetime "initial_timestamp", precision: nil
    t.string "owner"
    t.integer "tick_lower"
    t.integer "tick_upper"
    t.decimal "fee_growth_inside_last_x128_0"
    t.decimal "fee_growth_inside_last_x128_1"
    t.decimal "liquidity"
    t.jsonb "liquidity_changes", default: {}, null: false
    t.jsonb "token_0", default: {}, null: false
    t.jsonb "token_1", default: {}, null: false
    t.jsonb "pool", default: {}, null: false
    t.jsonb "events", default: {}, null: false
    t.jsonb "fees_claims", default: {}, null: false
    t.index ["uniswap_id"], name: "index_positions_on_uniswap_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "address", null: false
    t.string "telegram_chat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_users_on_address", unique: true
  end

  add_foreign_key "authentications", "users"
  add_foreign_key "notification_statuses", "users"
end
