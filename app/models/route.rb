class Route < ApplicationRecord
  has_one :agency
  has_many :trips

  default_scope { order(route_sort_order: 'asc', route_short_name: 'asc') }

  def self.hash_from_gtfs(row)
    agency = Agency.find_by_agency_gid(row.agency_id)

    record = {}
    record[:route_gid] = row.id
    record[:agency_gid] = row.agency_id
    record[:agency_id] = agency.id unless agency.nil?
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
