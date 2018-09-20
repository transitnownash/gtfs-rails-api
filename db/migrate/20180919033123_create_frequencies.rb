class CreateFrequencies < ActiveRecord::Migration[5.2]
  def change
    create_table :frequencies, id: false do |t|
      t.string :trip_id, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :headway_secs, null: false
      t.string :exact_times
      
      t.index :trip_id, unique: true
    end
  end
end
