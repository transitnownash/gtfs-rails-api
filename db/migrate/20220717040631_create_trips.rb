# frozen_string_literal: true

class CreateTrips < ActiveRecord::Migration[7.0]
  def change
    create_table :trips do |t|
      t.string 'route_gid', null: false
      t.integer 'route_id', null: true
      t.string 'service_gid', null: false
      t.integer 'calendar_id', null: true
      t.string 'trip_gid', null: false
      t.string 'trip_headsign'
      t.string 'trip_short_name'
      t.string 'direction_id'
      t.string 'block_gid'
      t.string 'shape_gid'
      t.integer 'shape_id'
      t.string 'wheelchair_accessible'
      t.string 'bikes_allowed'
      t.string 'start_time'
      t.string 'end_time'
      t.index ['trip_gid'], name: 'index_trips_on_trip_gid', unique: true
      t.timestamps
    end
  end
end
