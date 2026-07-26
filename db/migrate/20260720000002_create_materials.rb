class CreateMaterials < ActiveRecord::Migration[8.1]
  def change
    create_table :materials do |t|
      t.string :name, null: false
      t.string :code
      t.string :material_type
      t.string :unit, default: 'g'
      t.string :purity
      t.text :description
      t.string :aasm_state, default: 'active'

      t.timestamps
    end
    add_index :materials, :code, unique: true
    add_index :materials, :material_type
  end
end
