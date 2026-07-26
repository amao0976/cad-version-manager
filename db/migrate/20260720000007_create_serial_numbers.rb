class CreateSerialNumbers < ActiveRecord::Migration[8.1]
  def change
    create_table :serial_numbers do |t|
      t.references :variant, null: false, foreign_key: true
      t.references :batch, foreign_key: true
      t.string :code, null: false
      t.string :certificate_no
      t.decimal :weight, precision: 10, scale: 3
      t.string :aasm_state, default: 'in_stock'
      t.text :remark

      t.timestamps
    end
    add_index :serial_numbers, :code, unique: true
    add_index :serial_numbers, :variant_id
    add_index :serial_numbers, :batch_id
    add_index :serial_numbers, :certificate_no
  end
end
