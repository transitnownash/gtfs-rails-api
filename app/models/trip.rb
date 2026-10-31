# frozen_string_literal: true

##
# Trip Model
class Trip < ApplicationRecord
  belongs_to :route
  belongs_to :calendar
  has_many :stop_times, dependent: :destroy
  has_one :shape, foreign_key: :shape_gid, primary_key: :shape_gid, inverse_of: :trips, dependent: :destroy

  default_scope { order(start_time: :asc) }

  scope :active, ->(date = nil) { where(service_gid: active_service_gids(date)) }

  def self.active_service_gids(date = nil)
    day = date.blank? ? Time.zone.today : Date.parse(date)
    Rails.cache.fetch("trips/active_service_gids/#{day.iso8601}", expires_in: 10.minutes) do
      today = day.strftime('%Y-%m-%d')
      connection.select_values(<<~SQL.squish)
        SELECT c1.service_gid FROM calendars c1
        WHERE
          #{day.strftime('%A').downcase} = 1 AND
          '#{today}' BETWEEN start_date AND end_date
          AND c1.service_gid NOT IN (
            SELECT c2.service_gid FROM calendar_dates c2 WHERE date = '#{today}' AND exception_type = 2
          )
        UNION
        SELECT c3.service_gid FROM calendar_dates c3 WHERE c3.date = '#{today}' AND exception_type = 1
      SQL
    end
  end

  def block
    Trip.active.where(block_gid:).includes(:shape, :stop_times, { stop_times: :stop })
  end

  def active_on?(date = Time.zone.today)
    Trip.active_service_gids(date.to_s).include?(service_gid)
  end

  def as_json(_options = {})
    super(include: [shape: { only: %i[id shape_gid points], methods: :points }, stop_times: { methods: :stop }])
  end

  def self.hash_from_gtfs(row)
    route = Route.find_by(route_gid: row.route_id)
    calendar = Calendar.find_by(service_gid: row.service_id)
    shape = Shape.find_by(shape_gid: row.shape_id)

    record = {}
    record[:route_gid] = row.route_id
    record[:route_id] = route.id unless route.nil?
    record[:service_gid] = row.service_id
    record[:calendar_id] = calendar.id unless calendar.nil?
    record[:trip_gid] = row.id
    record[:trip_headsign] = row.headsign
    record[:trip_short_name] = row.short_name
    record[:direction_id] = row.direction_id
    record[:block_gid] = row.block_id
    record[:shape_gid] = row.shape_id
    record[:shape_id] = shape.id unless shape.nil?
    record[:wheelchair_accessible] = row.wheelchair_accessible
    record[:bikes_allowed] = row.bikes_allowed
    record
  end
end
