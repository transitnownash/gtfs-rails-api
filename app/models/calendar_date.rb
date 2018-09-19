class CalendarDate < ApplicationRecord
  def self.import(row)
    record = new
    record.service_id = row.service_id
    record.date = row.date
    record.exception_type = row.exception_type
    record.save!
  end
end
