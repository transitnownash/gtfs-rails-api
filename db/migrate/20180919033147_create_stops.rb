class CreateStops < ActiveRecord::Migration[5.2]
  def change
    create_table :stops, id: false do |t|
      t.string :stop_id, null: false
      t.string :stop_code
      t.string :stop_name, null: false
      t.string :stop_desc
      t.decimal :stop_lat, null: false
      t.decimal :stop_lon, null: false
      t.string :zone_id
      t.string :stop_url
      t.string :location_type
      t.string :parent_station
      t.string :stop_timezone
      t.string :wheelchair_boarding

      t.index :stop_id, unique: true
    end
  end
end
