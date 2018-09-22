class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers, id: false do |t|
      t.string :gtfs_id, null: false
      t.string :from_stop_id, null: false
      t.string :to_stop_id, null: false
      t.string :transfer_type, null: false
      t.integer :min_transfer_time

      t.index :gtfs_id, unique: true
      t.index [:from_stop_id, :to_stop_id], unique: true
    end
  end
end
