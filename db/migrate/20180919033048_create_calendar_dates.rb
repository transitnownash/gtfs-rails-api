class CreateCalendarDates < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_dates do |t|
      t.string :service_gid, null: false
      t.date :date, null: false
      t.string :exception_type, null: false

      t.index [:service_gid, :date], unique: true
    end
  end
end
