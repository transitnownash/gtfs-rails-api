# frozen_string_literal: true

##
# Indexes for the query paths that serve the bus map
class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    # Trip.active_service_gids filters calendar_dates by date; Calendar#calendar_dates by calendar_id
    change_table :calendar_dates, bulk: true do |t|
      t.index %i[date exception_type service_gid], name: 'index_calendar_dates_on_date_and_exception_type'
      t.index :calendar_id
    end

    # Trip queries filter by service/route and always sort by start_time (default scope)
    change_table :trips, bulk: true do |t|
      t.index %i[service_gid start_time]
      t.index %i[route_id start_time]
      t.remove_index :service_gid, name: 'index_stop_times_on_service_gid'
      t.remove_index :route_id, name: 'index_stop_times_on_route_id'
      t.rename_index 'index_stop_times_on_service_id', 'index_trips_on_calendar_id'
      t.rename_index 'index_stop_times_on_route_gid', 'index_trips_on_route_gid'
    end

    # Fallback lookups in set_stop / set_route, and child stop lookups
    change_table :stops, bulk: true do |t|
      t.index :stop_code
      t.index :parent_station_id
    end
    add_index :routes, :route_short_name

    # Stop endpoints filter by stop_gid and sort by arrival_time, stop_sequence.
    # trip_gid alone is the leading column of index_stop_times_on_trip_gid_and_stop_sequence.
    change_table :stop_times, bulk: true do |t|
      t.index %i[stop_gid arrival_time stop_sequence], name: 'index_stop_times_on_stop_gid_and_arrival_time'
      t.remove_index :stop_gid, name: 'index_stop_times_on_stop_gid'
      t.remove_index :trip_gid, name: 'index_stop_times_on_trip_gid'
    end
  end
end
