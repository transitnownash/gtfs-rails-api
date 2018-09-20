class Transfer < ApplicationRecord
  def self.hash_from_gtfs(row)
    record = {}
    record[:from_stop_id] = row.from_stop_id
    record[:to_stop_id] = row.to_stop_id
    record[:transfer_type] = row.type
    record[:min_transfer_time] = row.min_transfer_time
    record
  end
end
