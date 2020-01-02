class Calendar < ApplicationRecord
  has_many :calendar_dates
  has_many :trips

  scope :active, -> {
    dow = Time.current.strftime('%A').downcase
    joins(:calendar_dates)
      where(
        "start_date <= ? AND end_date >= ? AND #{dow} = 1",
        Date.today.strftime('%Y-%m-%d'),
        Date.today.strftime('%Y-%m-%d')
      )
      .where('service_gid NOT IN (SELECT cd.service_gid FROM calendar_dates cd WHERE cd.date =? AND cd.exception_type = 2)', Time.current.strftime('%Y-%m-%d'))
  }

  scope :active_on_date, -> (date) {
    dow = date.strftime('%A').downcase
    where(
      "start_date <= ? AND end_date >= ? AND #{dow} = 1",
      date.to_time,
      date.to_time
    )
    .where('service_gid NOT IN (SELECT cd.service_gid FROM calendar_dates cd WHERE cd.date =? AND cd.exception_type = 2)', date.strftime('%Y-%m-%d'))
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
