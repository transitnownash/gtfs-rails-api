# frozen_string_literal: true

##
# Route Model
class Route < ApplicationRecord
  has_one :agency, dependent: :destroy
  has_many :trips, dependent: :destroy

  default_scope { order(route_sort_order: 'asc', route_short_name: 'asc') }

  scope :active, lambda { |date = nil|
    if date.blank?
      today = Time.zone.today.strftime('%Y-%m-%d')
    else
      today = Date.parse(date).strftime('%Y-%m-%d')
    end
    distinct
      .joins('LEFT JOIN trips t ON t.route_id = routes.id')
      .where("
        t.service_gid IN (
          SELECT c.service_gid FROM calendars c WHERE '#{today}' BETWEEN c.start_date AND c.end_date
        )
      ")
  }

  def self.hash_from_gtfs(row)
    agency = Agency.find_by(agency_gid: row.agency_id)
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
