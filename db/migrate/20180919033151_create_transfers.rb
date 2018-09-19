class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers, id: false do |t|
      t.string :from_stop_id, null: false
      t.string :to_stop_id, null: false
      t.string :transfer_type, null: false
      t.integer :min_transfer_time
    end
  end
end
