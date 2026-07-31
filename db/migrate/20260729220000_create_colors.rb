class CreateColors < ActiveRecord::Migration[8.1]
  def change
    create_table :colors do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :color_type, null: false, default: 'plating'
      t.string :hex_code
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :colors, :code, unique: true
    add_index :colors, :color_type
    add_index :colors, :active
  end
end
