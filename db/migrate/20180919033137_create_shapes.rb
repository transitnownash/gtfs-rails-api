class CreateShapes < ActiveRecord::Migration[5.2]
  def change
    create_table :shapes, id: false do |t|
      t.string :shape_id, null: false
      t.decimal :shape_pt_lat, null: false
      t.decimal :shape_pt_lon, null: false
      t.integer :shape_pt_sequence, null: false
      t.decimal :shape_dist_traveled

      t.index [:shape_id, :shape_pt_sequence], unique: true
    end
  end
end
