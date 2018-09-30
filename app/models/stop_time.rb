class StopTime < ApplicationRecord
  belongs_to :trips
  belongs_to :stops

  default_scope { order(arrival_time: :asc, stop_sequence: :asc) }
  scope :future, -> { where(
    'arrival_time > ? OR departure_time > ?',
    DateTime.new(2000, 1, 1, DateTime.now.hour, DateTime.now.minute),
    DateTime.new(2000, 1, 1, DateTime.now.hour, DateTime.now.minute)
  ) }
  scope :past, -> { where(
    'arrival_time <= ? OR departure_time <= ?',
    DateTime.new(2000, 1, 1, DateTime.now.hour, DateTime.now.minute),
    DateTime.new(2000, 1, 1, DateTime.now.hour, DateTime.now.minute)
  ) }

  def self.hash_from_gtfs(row)
    record = {}
    record[:trip_gid] = row.trip_id
    record[:trip_id] = Trip.find_by_trip_gid(row.trip_id).id
    record[:arrival_time] = row.arrival_time
    record[:departure_time] = row.departure_time
    record[:stop_gid] = row.stop_id
    record[:stop_id] = Stop.find_by_stop_gid(row.stop_id).id
    record[:stop_sequence] = row.stop_sequence
    record[:stop_headsign] = row.stop_headsign
    record[:pickup_type] = row.pickup_type
    record[:drop_off_type] = row.drop_off_type
    record[:shape_dist_traveled] = row.shape_dist_traveled
    # record[:timepoint] = row.timepoint
    record
  end
end
