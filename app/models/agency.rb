class Agency < ApplicationRecord
  def self.import(row)
    record = new
    record.agency_id = row.id
    record.agency_name = row.name
    record.agency_url = row.url
    record.agency_timezone = row.timezone
    record.agency_lang = row.lang
    record.agency_phone = row.phone
    record.agency_fare_url = row.fare_url
    # record.agency_email = row.email
    record.save!
  end
end
