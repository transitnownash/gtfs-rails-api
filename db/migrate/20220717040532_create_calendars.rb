# frozen_string_literal: true

class CreateCalendars < ActiveRecord::Migration[7.0]
  def change
    create_table :calendars do |t|
      t.string 'service_gid', null: false
      t.boolean 'monday', null: false
      t.boolean 'tuesday', null: false
      t.boolean 'wednesday', null: false
      t.boolean 'thursday', null: false
      t.boolean 'friday', null: false
      t.boolean 'saturday', null: false
      t.boolean 'sunday', null: false
      t.date 'start_date', null: false
      t.date 'end_date', null: false
      t.index ['service_gid'], name: 'index_calendars_on_service_gid', unique: true
      t.timestamps
    end
  end
end
