class CreateCalendarDates < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_dates, id: false, primary_key: [:service_id, :date] do |t|
      t.string :service_id, null: false
      t.date :date, null: false
      t.string :exception_type, null: false

      t.index [:service_id, :date], unique: true
    end
  end
end
