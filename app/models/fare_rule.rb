# frozen_string_literal: true

##
# Fare Rule Model
class FareRule < ApplicationRecord
  has_one :fare_attribute, dependent: :destroy
  has_one :route, dependent: :destroy

  def self.hash_from_gtfs(row)
    route = Route.find_by(route_gid: row.route_id)
    record = {}
    record[:fare_gid] = row.fare_id
    record[:route_gid] = row.route_id
    record[:route_id] = route.id unless route.nil?
    record[:origin_gid] = row.origin_id
    record[:destination_gid] = row.destination_id
    record[:contains_gid] = row.contains_id
    record
  end
end
