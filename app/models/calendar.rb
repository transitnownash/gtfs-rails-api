class Calendar < ApplicationRecord
  def self.import(row)
    record = new
    record.service_id = row.service_id
    record.monday = row.monday
    record.tuesday = row.tuesday
    record.wednesday = row.wednesday
    record.thursday = row.thursday
    record.friday = row.friday
    record.saturday = row.saturday
    record.sunday = row.sunday
    record.start_date = row.start_date
    record.end_date = row.end_date
    record.save!
  end
end
