class FareRule < ApplicationRecord
  has_one :fare_attribute
  has_one :route

  def self.hash_from_gtfs(row)
    record = {}
    record[:fare_gid] = row.fare_id
    record[:route_gid] = row.route_id
    record[:origin_gid] = row.origin_id
    record[:destination_gid] = row.destination_id
    record[:contains_gid] = row.contains_id
    record
  end
end
