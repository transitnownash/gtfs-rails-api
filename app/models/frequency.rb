class Frequency < ApplicationRecord
  def self.import(row)
    record = new
    record.trip_id = row.trip_id
    record.start_time = row.start_time
    record.end_time = row.end_time
    record.headway_secs = row.headway_secs
    record.exact_times = row.exact_times
    record.save!
  end
end
