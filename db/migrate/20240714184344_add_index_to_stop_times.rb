class AddIndexToStopTimes < ActiveRecord::Migration[7.0]
  def change
    add_index :stop_times, :trip_id
    add_index :stop_times, :trip_gid
  end
end
