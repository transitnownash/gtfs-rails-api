class CreateTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :trips, id: false do |t|
      t.string :route_id, null: false
      t.string :service_id, null: false
      t.string :trip_id, null: false
      t.string :trip_headsign
      t.string :trip_short_name
      t.string :direction_id
      t.string :block_id
      t.string :shape_id
      t.string :wheelchair_accessible
      t.string :bikes_allowed
    end
  end
end
