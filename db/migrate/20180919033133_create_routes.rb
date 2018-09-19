class CreateRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :routes, id: false do |t|
      t.string :route_id, null: false
      t.string :agency_id
      t.string :route_short_name, null: false
      t.string :route_long_name, null: false
      t.string :route_desc
      t.string :route_type, null: false
      t.string :route_url
      t.string :route_color
      t.string :document
      t.string :route_text_color
      t.integer :route_sort_order
    end
  end
end
