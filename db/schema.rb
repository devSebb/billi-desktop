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

ActiveRecord::Schema[7.2].define(version: 2025_11_20_060454) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "expenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trip_id", null: false
    t.string "category"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.date "spent_at"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "payer_id"
    t.index ["payer_id"], name: "index_expenses_on_payer_id"
    t.index ["trip_id"], name: "index_expenses_on_trip_id"
  end

  create_table "price_snapshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.integer "month"
    t.string "season"
    t.string "category"
    t.decimal "average_amount", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "country", "month", "category"], name: "index_price_snapshots_on_loc_month_cat"
  end

  create_table "splits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "expense_id", null: false
    t.uuid "trip_participant_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_id"], name: "index_splits_on_expense_id"
    t.index ["trip_participant_id"], name: "index_splits_on_trip_participant_id"
  end

  create_table "trip_budgets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trip_id", null: false
    t.decimal "total_trip_cost", precision: 10, scale: 2
    t.decimal "per_person_cost", precision: 10, scale: 2
    t.decimal "lodging_total", precision: 10, scale: 2
    t.decimal "restaurants_total", precision: 10, scale: 2
    t.decimal "activities_total", precision: 10, scale: 2
    t.decimal "drinks_total", precision: 10, scale: 2
    t.decimal "shopping_total", precision: 10, scale: 2
    t.decimal "other_total", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_trip_budgets_on_trip_id"
  end

  create_table "trip_participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trip_id", null: false
    t.uuid "user_id"
    t.string "name"
    t.string "email"
    t.boolean "is_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_trip_participants_on_trip_id"
    t.index ["user_id"], name: "index_trip_participants_on_user_id"
  end

  create_table "trip_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trip_id", null: false
    t.string "lodging_style", default: "mixed"
    t.integer "hotel_nights", default: 0
    t.integer "airbnb_nights", default: 0
    t.integer "fancy_restaurant_meals", default: 0
    t.integer "casual_restaurant_meals", default: 0
    t.integer "street_food_meals", default: 0
    t.integer "activities_count", default: 0
    t.integer "nightlife_nights", default: 0
    t.string "shopping_budget_level", default: "medium"
    t.string "overall_comfort_level", default: "balanced"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_trip_preferences_on_trip_id"
  end

  create_table "trips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "name"
    t.string "destination_city"
    t.string "destination_country"
    t.date "start_date"
    t.date "end_date"
    t.integer "travelers_count"
    t.string "currency", default: "USD"
    t.string "status", default: "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "expenses", "trip_participants", column: "payer_id"
  add_foreign_key "expenses", "trips"
  add_foreign_key "splits", "expenses"
  add_foreign_key "splits", "trip_participants"
  add_foreign_key "trip_budgets", "trips"
  add_foreign_key "trip_participants", "trips"
  add_foreign_key "trip_participants", "users"
  add_foreign_key "trip_preferences", "trips"
  add_foreign_key "trips", "users"
end
