# frozen_string_literal: true

class StopTime < ApplicationRecord
  belongs_to :trip
  has_one :stop, foreign_key: :stop_gid, primary_key: :stop_gid

  default_scope { order(arrival_time: :asc, stop_sequence: :asc) }

  def as_json(_options = {})
    super include: [:stop]
  end

  def self.hash_from_gtfs(row)
    trip = Trip.find_by_trip_gid(row.trip_id)
    stop = Stop.find_by_stop_gid(row.stop_id)

    record = {}
    record[:trip_gid] = row.trip_id
    record[:trip_id] = trip.id unless trip.nil?
    record[:arrival_time] = row.arrival_time
    record[:departure_time] = row.departure_time
    record[:stop_gid] = row.stop_id
    record[:stop_id] = stop.id unless stop.nil?
    record[:stop_sequence] = row.stop_sequence
    record[:stop_headsign] = row.stop_headsign
    record[:pickup_type] = row.pickup_type
    record[:drop_off_type] = row.drop_off_type
    record[:shape_dist_traveled] = row.shape_dist_traveled
    record[:timepoint] = row.timepoint

    record
  end
end
