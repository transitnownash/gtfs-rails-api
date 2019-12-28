class CreateFrequencies < ActiveRecord::Migration[5.2]
  def change
    create_table :frequencies do |t|
      t.string :trip_gid, null: false
      t.string :start_time, null: false
      t.string :end_time, null: false
      t.integer :headway_secs, null: false
      t.string :exact_times

      t.index [:trip_gid, :start_time, :end_time], unique: true
    end
  end
end
