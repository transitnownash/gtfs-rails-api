# frozen_string_literal: true

##
# Create Frequencies
class CreateFrequencies < ActiveRecord::Migration[7.0]
  def change
    create_table :frequencies do |t|
      t.string 'trip_gid', null: false
      t.integer 'trip_id', null: true
      t.string 'start_time', null: false
      t.string 'end_time', null: false
      t.integer 'headway_secs', null: false
      t.string 'exact_times'
      t.index %w[trip_gid start_time end_time],
              name: 'index_frequencies_on_trip_gid_and_start_time_and_end_time', unique: true
      t.timestamps
    end
  end
end
