class CreateFareAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :fare_attributes do |t|
      t.string :fare_gid, null: false
      t.decimal :price, null: false
      t.string :currency_type, null: false
      t.string :payment_method, null: false
      t.string :agency_gid
      t.string :transfer_duration

      t.index :fare_gid, unique: true
    end
  end
end
