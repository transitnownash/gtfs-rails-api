class CreateRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :routes do |t|
      t.string "route_gid", null: false
      t.string "agency_gid"
      t.integer "agency_id", null: true
      t.string "route_short_name", null: false
      t.string "route_long_name", null: false
      t.string "route_desc"
      t.string "route_type", null: false
      t.string "route_url"
      t.string "route_color"
      t.string "route_text_color"
      t.integer "route_sort_order"
      t.index ["route_gid"], name: "index_routes_on_route_gid", unique: true
      t.timestamps
    end
  end
end
