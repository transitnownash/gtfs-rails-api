class FareAttribute < ApplicationRecord
  self.primary_key = 'fare_id'

  def self.hash_from_gtfs(row)
    record = {}
    record[:fare_id] = row.fare_id
    record[:price] = row.price
    record[:currency_type] = row.currency_type
    record[:payment_method] = row.payment_method
    record[:agency_id] = row.agency_id
    record[:transfer_duration] = row.transfer_duration
    record
  end
end
