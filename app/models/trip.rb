class Trip < ApplicationRecord
  has_one :calendar
  has_one :route
  has_many :shapes
  has_many :stop_times

  def self.hash_from_gtfs(row)
    record = {}
    record[:route_gid] = row.route_id
    record[:route_id] = Route.find_by_route_gid(row.route_id)
    record[:service_gid] = row.service_id
    record[:trip_gid] = row.id
    record[:trip_headsign] = row.headsign
    record[:trip_short_name] = row.short_name
    record[:direction_gid] = row.direction_id
    record[:block_gid] = row.block_id
    record[:shape_gid] = row.shape_id
    record[:wheelchair_accessible] = row.wheelchair_accessible
    # record[:bikes_allowed] = row.bikes_allowed
    record
  end
end
