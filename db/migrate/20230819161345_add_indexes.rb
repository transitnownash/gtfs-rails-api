# frozen_string_literal: true

##
# Create Trips
class AddIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :trips, ['shape_id'], name: 'index_trips_on_shape_id'
    add_index :trips, ['calendar_id'], name: 'index_stop_times_on_service_id'
    add_index :trips, ['route_id'], name: 'index_stop_times_on_route_id'
    add_index :trips, ['shape_gid'], name: 'index_trips_on_shape_gid'
    add_index :trips, ['block_gid'], name: 'index_trips_on_block_gid'
    add_index :trips, ['service_gid'], name: 'index_stop_times_on_service_gid'
    add_index :trips, ['route_gid'], name: 'index_stop_times_on_route_gid'
    add_index :stop_times, ['stop_id'], name: 'index_stop_times_on_stop_id'
    add_index :stop_times, ['stop_gid'], name: 'index_stop_times_on_stop_gid'
  end
end
