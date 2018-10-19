class CalendarDate < ApplicationRecord
  default_scope { order(date: :asc) }

  def self.hash_from_gtfs(row)
    calendar = Calendar.find_by_service_gid(row.service_id)

    record = {}
    record[:service_gid] = row.service_id
    record[:calendar_id] = calendar ? calendar.id : 0
    record[:date] = row.date
    record[:exception_type] = row.exception_type
    record
  end
end
