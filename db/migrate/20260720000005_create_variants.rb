class CreateVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :sku_code, null: false
      t.references :material, foreign_key: true
      t.string :size
      t.string :color
      t.string :gemstone
      t.decimal :weight_override, precision: 10, scale: 3
      t.string :aasm_state, default: 'active'

      t.timestamps
    end
    add_index :variants, :sku_code, unique: true
    add_index :variants, :product_id
    add_index :variants, :material_id
  end
end
