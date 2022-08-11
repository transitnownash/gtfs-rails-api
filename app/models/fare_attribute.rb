# frozen_string_literal: true

##
# Fare Attribute Model
class FareAttribute < ApplicationRecord
  has_one :agency, dependent: :destroy
  has_many :fare_rules, dependent: :destroy

  def self.hash_from_gtfs(row)
    record = {}
    record[:fare_gid] = row.fare_id
    record[:price] = row.price
    record[:currency_type] = row.currency_type
    record[:payment_method] = row.payment_method
    # record[:agency_gid] = row.agency_id
    record[:transfer_duration] = row.transfer_duration
    record
  end
end
