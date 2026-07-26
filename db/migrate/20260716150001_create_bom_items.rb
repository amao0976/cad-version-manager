class CreateBomItems < ActiveRecord::Migration[8.1]
  def change
    create_table :bom_items do |t|
      t.references :product_bom, null: false, foreign_key: true
      t.references :design_drawing, foreign_key: true
      t.string :part_number, null: false
      t.string :part_name, null: false
      t.string :material
      t.string :specification
      t.decimal :quantity, null: false, default: 1, precision: 10, scale: 2
      t.string :unit, default: '件'
      t.decimal :weight, precision: 10, scale: 4
      t.string :source, default: '自制'
      t.integer :level, default: 1
      t.references :parent_id, foreign_key: { to_table: :bom_items }

      t.timestamps
    end
  end
end