class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers do |t|
      t.string :from_stop_gid, null: false
      t.string :to_stop_gid, null: false
      t.string :transfer_type, null: false
      t.integer :min_transfer_time

      t.index [:from_stop_gid, :to_stop_gid], unique: true
    end
  end
end
