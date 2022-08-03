# frozen_string_literal: true

class CreateFareRules < ActiveRecord::Migration[7.0]
  def change
    create_table :fare_rules do |t|
      t.string 'fare_gid', null: false
      t.string 'route_gid'
      t.integer 'route_id', null: true
      t.string 'origin_gid'
      t.string 'destination_gid'
      t.string 'contains_gid'
      t.timestamps
    end
  end
end
