# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_19_033157) do

  create_table "agencies", id: false, force: :cascade do |t|
    t.string "agency_id"
    t.string "agency_name", null: false
    t.string "agency_url", null: false
    t.string "agency_timezone"
    t.string "agency_lang"
    t.string "agency_phone"
    t.string "agency_fare_url"
    t.string "agency_email"
    t.index ["agency_id"], name: "index_agencies_on_agency_id", unique: true
  end

  create_table "calendar_dates", id: false, force: :cascade do |t|
    t.string "service_id", null: false
    t.date "date", null: false
    t.string "exception_type", null: false
    t.index ["service_id", "date"], name: "index_calendar_dates_on_service_id_and_date", unique: true
  end

  create_table "calendars", id: false, force: :cascade do |t|
    t.string "service_id", null: false
    t.boolean "monday", null: false
    t.boolean "tuesday", null: false
    t.boolean "wednesday", null: false
    t.boolean "thursday", null: false
    t.boolean "friday", null: false
    t.boolean "saturday", null: false
    t.boolean "sunday", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.index ["service_id"], name: "index_calendars_on_service_id", unique: true
  end

  create_table "fare_attributes", id: false, force: :cascade do |t|
    t.string "fare_id", null: false
    t.decimal "price", null: false
    t.string "currency_type", null: false
    t.string "payment_method", null: false
    t.string "agency_id"
    t.string "transfer_duration"
    t.index ["fare_id"], name: "index_fare_attributes_on_fare_id", unique: true
  end

  create_table "fare_rules", id: false, force: :cascade do |t|
    t.string "fare_id", null: false
    t.string "route_id"
    t.string "origin_id"
    t.string "destination_id"
    t.string "contains_id"
  end

  create_table "feed_infos", id: false, force: :cascade do |t|
    t.string "feed_publisher_name", null: false
    t.string "feed_publisher_url", null: false
    t.string "feed_lang", null: false
    t.date "feed_start_date"
    t.date "feed_end_date"
    t.string "feed_version"
  end

  create_table "frequencies", id: false, force: :cascade do |t|
    t.string "trip_id", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "headway_secs", null: false
    t.string "exact_times"
  end

  create_table "routes", id: false, force: :cascade do |t|
    t.string "route_id", null: false
    t.string "agency_id"
    t.string "route_short_name", null: false
    t.string "route_long_name", null: false
    t.string "route_desc"
    t.string "route_type", null: false
    t.string "route_url"
    t.string "route_color"
    t.string "route_text_color"
    t.integer "route_sort_order"
    t.index ["route_id"], name: "index_routes_on_route_id", unique: true
  end

  create_table "shapes", id: false, force: :cascade do |t|
    t.string "shape_id", null: false
    t.decimal "shape_pt_lat", null: false
    t.decimal "shape_pt_lon", null: false
    t.integer "shape_pt_sequence", null: false
    t.decimal "shape_dist_traveled"
    t.index ["shape_id", "shape_pt_sequence"], name: "index_shapes_on_shape_id_and_shape_pt_sequence", unique: true
  end

  create_table "stop_times", id: false, force: :cascade do |t|
    t.string "trip_id", null: false
    t.time "arrival_time", null: false
    t.time "departure_time", null: false
    t.string "stop_id", null: false
    t.integer "stop_sequence", null: false
    t.string "stop_headsign"
    t.string "pickup_type"
    t.string "drop_off_type"
    t.decimal "shape_dist_traveled"
    t.string "timepoint"
    t.index ["trip_id", "stop_sequence"], name: "index_stop_times_on_trip_id_and_stop_sequence", unique: true
  end

  create_table "stops", id: false, force: :cascade do |t|
    t.string "stop_id", null: false
    t.string "stop_code"
    t.string "stop_name", null: false
    t.string "stop_desc"
    t.decimal "stop_lat", null: false
    t.decimal "stop_lon", null: false
    t.string "zone_id"
    t.string "stop_url"
    t.string "location_type"
    t.string "parent_station"
    t.string "stop_timezone"
    t.string "wheelchair_boarding"
    t.index ["stop_id"], name: "index_stops_on_stop_id", unique: true
  end

  create_table "transfers", id: false, force: :cascade do |t|
    t.string "from_stop_id", null: false
    t.string "to_stop_id", null: false
    t.string "transfer_type", null: false
    t.integer "min_transfer_time"
    t.index ["from_stop_id", "to_stop_id"], name: "index_transfers_on_from_stop_id_and_to_stop_id", unique: true
  end

  create_table "trips", id: false, force: :cascade do |t|
    t.string "route_id", null: false
    t.string "service_id", null: false
    t.string "trip_id", null: false
    t.string "trip_headsign"
    t.string "trip_short_name"
    t.string "direction_id"
    t.string "block_id"
    t.string "shape_id"
    t.string "wheelchair_accessible"
    t.string "bikes_allowed"
    t.index ["trip_id"], name: "index_trips_on_trip_id", unique: true
  end

end
