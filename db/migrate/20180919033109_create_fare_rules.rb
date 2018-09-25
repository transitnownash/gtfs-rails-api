class CreateFareRules < ActiveRecord::Migration[5.2]
  def change
    create_table :fare_rules do |t|
      t.string :fare_gid, null: false
      t.string :route_gid
      t.string :origin_gid
      t.string :destination_gid
      t.string :contains_gid
    end
  end
end
