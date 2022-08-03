# frozen_string_literal: true

class CreateFareAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :fare_attributes do |t|
      t.string 'fare_gid', null: false
      t.decimal 'price', precision: 10, null: false
      t.string 'currency_type', null: false
      t.string 'payment_method', null: false
      t.string 'agency_gid'
      t.string 'transfer_duration'
      t.index ['fare_gid'], name: 'index_fare_attributes_on_fare_gid', unique: true
      t.timestamps
    end
  end
end
