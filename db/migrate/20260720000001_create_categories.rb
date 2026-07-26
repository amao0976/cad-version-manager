class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :code
      t.references :parent, foreign_key: { to_table: :categories }
      t.integer :level, default: 0
      t.string :aasm_state, default: 'active'
      t.text :description

      t.timestamps
    end
    add_index :categories, :parent_id
    add_index :categories, :code, unique: true
  end
end
