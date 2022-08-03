# frozen_string_literal: true

class CreateShapes < ActiveRecord::Migration[7.0]
  def change
    create_table :shapes do |t|
      t.string 'shape_gid', null: false
      t.text 'shape_points', limit: 4_294_967_295, null: false
      t.index ['shape_gid'], name: 'index_shapes_on_shape_gid', unique: true
      t.timestamps
    end
  end
end
