class Transfer < ApplicationRecord
  def self.import(row)
    record = new
    record.from_stop_id = row.from_stop_id
    record.to_stop_id = row.to_stop_id
    record.transfer_type = row.type
    record.min_transfer_time = row.min_transfer_time
    record.save!
  end
end
