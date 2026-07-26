class CreateMaterialPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :material_prices do |t|
      t.references :material, null: false, foreign_key: true
      t.date :price_date, null: false
      t.decimal :unit_price, precision: 12, scale: 4, null: false
      t.string :currency, default: 'CNY'
      t.string :source

      t.timestamps
    end
    add_index :material_prices, [:material_id, :price_date], unique: true
  end
end
