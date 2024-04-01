# frozen_string_literal: true

##
# Create Retail Locations
class CreateRetailLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :retail_locations do |t|
      t.string 'location_code', unique: true, null: false
      t.string 'name'
      t.string 'address'
      t.string 'city'
      t.string 'state'
      t.string 'zip'
      t.boolean 'is_active', default: false, null: false
      t.boolean 'can_buy_media', default: false, null: false
      t.boolean 'can_reload_media', default: false, null: false
      t.decimal 'latitude', precision: 10, scale: 6, null: false
      t.decimal 'longitude', precision: 10, scale: 6, null: false
      t.timestamps
    end
  end
end
