class Route < ApplicationRecord
  self.primary_key = 'trip_id'

  def self.hash_from_gtfs(row)
    record = {}
    record[:route_id] = row.id
    record[:agency_id] = row.agency_id
    record[:route_short_name] = row.short_name
    record[:route_long_name] = row.long_name
    record[:route_desc] = row.desc
    record[:route_type] = row.type
    record[:route_url] = row.url
    record[:route_color] = row.color
    record[:route_text_color] = row.text_color
    record
  end
end
