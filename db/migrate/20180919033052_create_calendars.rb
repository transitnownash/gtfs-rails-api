class CreateCalendars < ActiveRecord::Migration[5.2]
  def change
    create_table :calendars, id: false do |t|
      t.string :service_id, null: false
      t.boolean :monday, null: false
      t.boolean :tuesday, null: false
      t.boolean :wednesday, null: false
      t.boolean :thursday, null: false
      t.boolean :friday, null: false
      t.boolean :saturday, null: false
      t.boolean :sunday, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
    end
  end
end
