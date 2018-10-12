class CreateStopTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :stop_times do |t|
      t.string :trip_gid, null: false
      t.integer :trip_id, null: false
      t.time :arrival_time, null: false
      t.time :departure_time, null: false
      t.string :stop_gid, null: false
      t.integer :stop_id, null: false
      t.integer :stop_sequence, null: false
      t.string :stop_headsign
      t.string :pickup_type
      t.string :drop_off_type
      t.decimal :shape_dist_traveled, { precision: 10, scale: 6 }
      t.string :timepoint

      t.index [:trip_gid, :stop_sequence], unique: true
    end
  end
end
