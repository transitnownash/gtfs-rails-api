class StopTime < ApplicationRecord
self.primary_key = 'gtfs_id'

  def self.hash_from_gtfs(row)
    record = {}
    record[:gtfs_id] = "#{row.trip_id}|#{row.stop_sequence}"
    record[:trip_id] = row.trip_id
    record[:arrival_time] = row.arrival_time
    record[:departure_time] = row.departure_time
    record[:stop_id] = row.stop_id
    record[:stop_sequence] = row.stop_sequence
    record[:stop_headsign] = row.stop_headsign
    record[:pickup_type] = row.pickup_type
    record[:drop_off_type] = row.drop_off_type
    record[:shape_dist_traveled] = row.shape_dist_traveled
    # record[:timepoint] = row.timepoint
    record
  end
end
