class CreateAgencies < ActiveRecord::Migration[7.0]
  def change
    create_table :agencies do |t|
      t.string "agency_gid"
      t.string "agency_name", null: false
      t.string "agency_url", null: false
      t.string "agency_timezone"
      t.string "agency_lang"
      t.string "agency_phone"
      t.string "agency_fare_url"
      t.string "agency_email"
      t.index ["agency_gid"], name: "index_agencies_on_agency_gid", unique: true
      t.timestamps
    end
  end
end
