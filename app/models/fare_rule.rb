class FareRule < ApplicationRecord
  self.primary_key = 'gtfs_id'

  def self.hash_from_gtfs(row)
    record = {}
    record[:gtfs_id] = "#{row.fare_id}|#{row.route_id}|#{row.origin_id}|#{row.destination_id}|#{row.contains_id}"
    record[:fare_id] = row.fare_id
    record[:route_id] = row.route_id
    record[:origin_id] = row.origin_id
    record[:destination_id] = row.destination_id
    record[:contains_id] = row.contains_id
    record
  end
end
