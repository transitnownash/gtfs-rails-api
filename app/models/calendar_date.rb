class CalendarDate < ApplicationRecord
  self.primary_key = 'service_id'
  
  def self.hash_from_gtfs(row)
    record = {}
    record[:service_id] = row.service_id
    record[:date] = row.date
    record[:exception_type] = row.exception_type
    record
  end
end
