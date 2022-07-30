class CreateTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers do |t|
      t.string "from_stop_gid", null: false
      t.integer "from_stop_id", null: true
      t.string "to_stop_gid", null: false
      t.integer "to_stop_id", null: true
      t.string "transfer_type", null: false
      t.integer "min_transfer_time"
      t.index ["from_stop_gid", "to_stop_gid"], name: "index_transfers_on_from_stop_gid_and_to_stop_gid", unique: true
      t.timestamps
    end
  end
end
