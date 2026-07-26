class CreateBatches < ActiveRecord::Migration[8.1]
  def change
    create_table :batches do |t|
      t.references :variant, null: false, foreign_key: true
      t.string :batch_no, null: false
      t.integer :quantity, null: false, default: 0
      t.date :production_date
      t.string :aasm_state, default: 'in_production'
      t.text :remark

      t.timestamps
    end
    add_index :batches, :batch_no, unique: true
    add_index :batches, :variant_id
    add_index :batches, :aasm_state
  end
end
