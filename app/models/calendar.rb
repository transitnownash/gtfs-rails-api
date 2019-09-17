class Calendar < ApplicationRecord
  has_many :calendar_dates
  has_many :trips

  scope :find_by_date, -> (date) {
    dow = date.strftime('%A').downcase
    where(
      "start_date <= ? AND end_date >= ? AND #{dow} = 1",
      date.to_time,
      date.to_time
    )
  }

  def self.hash_from_gtfs(row)
    record = {}
    record[:service_gid] = row.service_id
    record[:monday] = row.monday
    record[:tuesday] = row.tuesday
    record[:wednesday] = row.wednesday
    record[:thursday] = row.thursday
    record[:friday] = row.friday
    record[:saturday] = row.saturday
    record[:sunday] = row.sunday
    record[:start_date] = row.start_date
    record[:end_date] = row.end_date
    record
  end
end
