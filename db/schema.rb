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

ActiveRecord::Schema[7.2].define(version: 2026_02_04_221617) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "split_type_enum", ["fixed", "equal", "percentage"]

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country"], name: "index_cities_on_country"
    t.index ["name"], name: "index_cities_on_name"
    t.index ["slug"], name: "index_cities_on_slug"
  end

  create_table "expenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trip_id", null: false
    t.string "category"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.date "spent_at"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "payer_participant_id"
    t.index ["payer_participant_id"], name: "index_expenses_on_payer_participant_id"
    t.index ["trip_id"], name: "index_expenses_on_trip_id"
  end

  create_table "price_snapshot_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "price_snapshot_id", null: false
    t.uuid "city_id", null: false
    t.string "category", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.string "source"
    t.datetime "collected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id", "category", "collected_at"], name: "index_price_items_on_city_cat_collected"
    t.index ["city_id"], name: "index_price_snapshot_items_on_city_id"
    t.index ["price_snapshot_id"], name: "index_price_snapshot_items_on_price_snapshot_id"
  end

  create_table "price_snapshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "currency", default: "USD"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "city_id", null: false
    t.string "source"
    t.jsonb "data", default: {}
    t.datetime "collected_at"
    t.index ["city_id", "collected_at"], name: "index_price_snapshots_on_city_id_and_collected_at"
    t.index ["city_id"], name: "index_price_snapshots_on_city_id"
    t.index ["data"], name: "index_price_snapshots_on_data", using: :gin
    t.index ["source"], name: "index_price_snapshots_on_source"
  end

  create_table "splits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "expense_id", null: false
    t.uuid "trip_participant_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "split_type", default: "fixed", null: false, enum_type: "split_type_enum"
    t.decimal "weight", precision: 10, scale: 2
    t.index ["expense_id", "trip_participant_id"], name: "index_splits_on_expense_id_and_trip_participant_id"
    t.index ["expense_id"], name: "index_splits_on_expense_id"
    t.index ["trip_participant_id"], name: "index_splits_on_trip_participant_id"
  end

  create_table "trip_budget_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trip_budget_id", null: false
    t.uuid "trip_id", null: false
    t.string "category", null: false
    t.decimal "amount", precision: 10, scale: 2, default: "0.0"
    t.string "currency", default: "USD"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_budget_id"], name: "index_trip_budget_items_on_trip_budget_id"
    t.index ["trip_id", "category"], name: "index_trip_budget_items_on_trip_id_and_category"
    t.index ["trip_id"], name: "index_trip_budget_items_on_trip_id"
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
    t.index ["trip_id", "user_id"], name: "index_trip_participants_on_trip_id_and_user_id", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["trip_id"], name: "index_trip_participants_on_trip_id"
    t.index ["user_id"], name: "index_trip_participants_on_user_id"
    t.check_constraint "user_id IS NOT NULL OR name IS NOT NULL", name: "check_trip_participants_user_or_name"
  end

  create_table "trip_preference_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trip_preference_id", null: false
    t.uuid "trip_id", null: false
    t.string "category", null: false
    t.decimal "value", precision: 10, scale: 2
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id", "category"], name: "index_trip_preference_items_on_trip_id_and_category"
    t.index ["trip_id"], name: "index_trip_preference_items_on_trip_id"
    t.index ["trip_preference_id"], name: "index_trip_preference_items_on_trip_preference_id"
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
    t.index ["end_date"], name: "index_trips_on_end_date"
    t.index ["start_date"], name: "index_trips_on_start_date"
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
    t.string "display_currency", default: "USD", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "expenses", "trip_participants", column: "payer_participant_id"
  add_foreign_key "expenses", "trips"
  add_foreign_key "price_snapshot_items", "cities"
  add_foreign_key "price_snapshot_items", "price_snapshots"
  add_foreign_key "price_snapshots", "cities"
  add_foreign_key "splits", "expenses"
  add_foreign_key "splits", "trip_participants"
  add_foreign_key "trip_budget_items", "trip_budgets"
  add_foreign_key "trip_budget_items", "trips"
  add_foreign_key "trip_budgets", "trips"
  add_foreign_key "trip_participants", "trips"
  add_foreign_key "trip_participants", "users"
  add_foreign_key "trip_preference_items", "trip_preferences"
  add_foreign_key "trip_preference_items", "trips"
  add_foreign_key "trip_preferences", "trips"
  add_foreign_key "trips", "users"
end
