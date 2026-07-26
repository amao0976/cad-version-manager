class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :product_code, null: false
      t.references :category, foreign_key: true
      t.references :design_drawing, foreign_key: true
      t.references :main_material, foreign_key: { to_table: :materials }
      t.decimal :base_weight, precision: 10, scale: 3
      t.text :description
      t.string :aasm_state, default: 'draft'

      t.timestamps
    end
    add_index :products, :product_code, unique: true
    add_index :products, :category_id
    add_index :products, :aasm_state
  end
end
