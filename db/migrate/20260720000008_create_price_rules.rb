class CreatePriceRules < ActiveRecord::Migration[8.1]
  def change
    create_table :price_rules do |t|
      t.string :name, null: false
      t.references :category, foreign_key: true
      t.references :material, foreign_key: true
      t.integer :priority, default: 0
      t.decimal :labor_fee, precision: 10, scale: 2, default: 0
      t.decimal :markup_rate, precision: 5, scale: 3, default: 1.0
      t.string :aasm_state, default: 'active'

      t.timestamps
    end
    add_index :price_rules, [:category_id, :material_id]
    add_index :price_rules, :priority
    add_index :price_rules, :aasm_state
  end
end
