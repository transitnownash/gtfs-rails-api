class Frequency < ApplicationRecord  
  self.primary_key = 'gtfs_id'

  def self.hash_from_gtfs(row)
    record = {}
    record[:gtfs_id] = "#{row.trip_id}|#{row.start_time}|#{row.end_time}"
    record[:trip_id] = row.trip_id
    record[:start_time] = row.start_time
    record[:end_time] = row.end_time
    record[:headway_secs] = row.headway_secs
    record[:exact_times] = row.exact_times
    record
  end
end
