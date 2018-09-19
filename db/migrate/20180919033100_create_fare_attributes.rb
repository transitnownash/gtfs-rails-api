class CreateFareAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :fare_attributes, id: false do |t|
      t.string :fare_id, null: false
      t.decimal :price, null: false
      t.string :currency_type, null: false
      t.string :payment_method, null: false
      t.string :agency_id
      t.string :transfer_duration
    end
  end
end
