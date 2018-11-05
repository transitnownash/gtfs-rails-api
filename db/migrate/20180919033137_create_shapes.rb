class CreateShapes < ActiveRecord::Migration[5.2]
  def change
    create_table :shapes do |t|
      t.string :shape_gid, null: false
      t.text :shape_points, limit: 4_294_967_295, null: false

      t.index :shape_gid, unique: true
    end
  end
end
