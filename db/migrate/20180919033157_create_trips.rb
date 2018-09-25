class CreateTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :trips do |t|
      t.string :route_gid, null: false
      t.string :service_gid, null: false
      t.string :trip_gid, null: false
      t.string :trip_headsign
      t.string :trip_short_name
      t.string :direction_gid
      t.string :block_gid
      t.string :shape_gid
      t.string :wheelchair_accessible
      t.string :bikes_allowed

      t.index :trip_gid, unique: true
    end
  end
end
