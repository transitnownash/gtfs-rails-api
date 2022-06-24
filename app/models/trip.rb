class Trip < ApplicationRecord
  belongs_to :route
  belongs_to :calendar
  has_many :stop_times
  has_one :shape, foreign_key: :shape_gid, primary_key: :shape_gid

  default_scope { order(start_time: :asc) }

  scope :active, -> {
    joins(:calendar)
      .where(calendar_id: Calendar.active)
  }

  def as_json(_options = {})
    super include: [:stop_times, shape: {only: [:id, :shape_gid, :points], methods: :points}]
  end

  def self.hash_from_gtfs(row)
    record = {}
    record[:route_gid] = row.route_id
    record[:route_id] = Route.find_by_route_gid(row.route_id).id
    record[:service_gid] = row.service_id
    record[:calendar_id] = Calendar.find_by_service_gid(row.service_id).id
    record[:trip_gid] = row.id
    record[:trip_headsign] = row.headsign
    record[:trip_short_name] = row.short_name
    record[:direction_id] = row.direction_id
    record[:block_gid] = row.block_id
    record[:shape_gid] = row.shape_id
    record[:wheelchair_accessible] = row.wheelchair_accessible
    record[:bikes_allowed] = row.bikes_allowed
    record
  end
end
