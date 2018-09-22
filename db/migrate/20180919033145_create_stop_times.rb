class CreateStopTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :stop_times, id: false do |t|
      t.string :gtfs_id, null: false
      t.string :trip_id, null: false
      t.time :arrival_time, null: false
      t.time :departure_time, null: false
      t.string :stop_id, null: false
      t.integer :stop_sequence, null: false
      t.string :stop_headsign
      t.string :pickup_type
      t.string :drop_off_type
      t.decimal :shape_dist_traveled
      t.string :timepoint

      t.index :gtfs_id, unique: true
      t.index [:trip_id, :stop_sequence], unique: true
    end
  end
end
