class CreateFareRules < ActiveRecord::Migration[5.2]
  def change
    create_table :fare_rules, id: false do |t|
      t.string :gtfs_id, null: false
      t.string :fare_id, null: false
      t.string :route_id
      t.string :origin_id
      t.string :destination_id
      t.string :contains_id

      t.index :gtfs_id, unique: true
    end
  end
end
