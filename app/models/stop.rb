# frozen_string_literal: true

##
# Stop Model
class Stop < ApplicationRecord
  has_many :stop_times, dependent: :destroy
  has_many :child_stops, class_name: 'Stop', foreign_key: 'parent_station', inverse_of: :parent_station, dependent: :destroy
  belongs_to :parent_station, class_name: 'Stop', optional: true
  acts_as_mappable lat_column_name: :stop_lat,
                   lng_column_name: :stop_lon,
                   distance_field_name: :distance,
                   default_units: :meters

  def self.hash_from_gtfs(row)
    record = {}
    record[:stop_gid] = row.id
    record[:stop_code] = row.code
    record[:stop_name] = row.name
    record[:stop_desc] = row.desc
    record[:stop_lat] = row.lat
    record[:stop_lon] = row.lon
    record[:zone_gid] = row.zone_id
    record[:stop_url] = row.url
    record[:location_type] = row.location_type
    record[:parent_station_gid] = row.parent_station
    # record[:parent_station_id]
    record[:stop_timezone] = row.timezone
    record[:wheelchair_boarding] = row.wheelchair_boarding
    record
  end
end
