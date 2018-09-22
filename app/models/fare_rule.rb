class FareRule < ApplicationRecord
  def self.hash_from_gtfs(row)
    record = {}
    record[:fare_id] = row.fare_id
    record[:route_id] = row.route_id
    record[:origin_id] = row.origin_id
    record[:destination_id] = row.destination_id
    record[:contains_id] = row.contains_id
    record
  end
end
