class FareAttribute < ApplicationRecord
  def self.import(row)
    record = new
    record.fare_id = fare_id
    record.price = price
    record.currency_type = currency_type
    record.payment_method = payment_method
    record.agency_id = agency_id
    record.transfer_duration = transfer_duration
    record.save!
  end
end
