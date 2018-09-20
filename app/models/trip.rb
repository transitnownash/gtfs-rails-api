class Trip < ApplicationRecord
  def self.hash_from_gtfs(row)
    record = {}
    record[:route_id] = row.route_id
    record[:service_id] = row.service_id
    record[:trip_id] = row.id
    record[:trip_headsign] = row.headsign
    record[:trip_short_name] = row.short_name
    record[:direction_id] = row.direction_id
    record[:block_id] = row.block_id
    record[:shape_id] = row.shape_id
    record[:wheelchair_accessible] = row.wheelchair_accessible
    # record[:bikes_allowed] = row.bikes_allowed
    record
  end
end
