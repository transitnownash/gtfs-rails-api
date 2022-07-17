class CreateStopTimes < ActiveRecord::Migration[7.0]
  def change
    create_table :stop_times do |t|
      t.string "trip_gid", null: false
      t.integer "trip_id", null: false
      t.string "arrival_time", null: false
      t.string "departure_time", null: false
      t.string "stop_gid", null: false
      t.integer "stop_id", null: false
      t.integer "stop_sequence", null: false
      t.string "stop_headsign"
      t.string "pickup_type"
      t.string "drop_off_type"
      t.decimal "shape_dist_traveled", precision: 16, scale: 6
      t.string "timepoint"
      t.index ["trip_gid", "stop_sequence"], name: "index_stop_times_on_trip_gid_and_stop_sequence", unique: true
      t.timestamps
    end
  end
end
