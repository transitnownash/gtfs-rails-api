# frozen_string_literal: true

class CreateCalendarDates < ActiveRecord::Migration[7.0]
  def change
    create_table :calendar_dates do |t|
      t.string 'service_gid', null: false
      t.integer 'calendar_id', null: false
      t.date 'date', null: false
      t.string 'exception_type', null: false
      t.index %w[service_gid date], name: 'index_calendar_dates_on_service_gid_and_date', unique: true
      t.timestamps
    end
  end
end
