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

ActiveRecord::Schema[7.0].define(version: 2023_04_21_121411) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string "code", null: false
    t.decimal "usd_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_currencies_on_code", unique: true
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "from_currency_id", null: false
    t.bigint "to_currency_id", null: false
    t.decimal "max_price", null: false
    t.decimal "min_price", null: false
    t.integer "notification_status", default: 0, null: false
    t.integer "rebalance_threshold_percents", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_currency_id"], name: "index_positions_on_from_currency_id"
    t.index ["to_currency_id"], name: "index_positions_on_to_currency_id"
  end

  add_foreign_key "positions", "currencies", column: "from_currency_id"
  add_foreign_key "positions", "currencies", column: "to_currency_id"
end
