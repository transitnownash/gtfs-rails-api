# frozen_string_literal: true

class Frequency < ApplicationRecord
  def self.hash_from_gtfs(row)
    trip = Trip.find_by_trip_gid(row.trip_id)

    record = {}
    record[:trip_gid] = row.trip_id
    record[:trip_id] = trip.id unless trip.nil?
    record[:start_time] = row.start_time
    record[:end_time] = row.end_time
    record[:headway_secs] = row.headway_secs
    record[:exact_times] = row.exact_times
    record
  end
end
