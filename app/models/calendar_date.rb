class CalendarDate < ApplicationRecord  
  def self.hash_from_gtfs(row)
    record = {}
    record[:service_gid] = row.service_id
    record[:date] = row.date
    record[:exception_type] = row.exception_type
    record
  end
end
