class CreateProductImages < ActiveRecord::Migration[8.0]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.string :image, null: false
      t.integer :position, default: 0
      t.boolean :is_cover, default: false, null: false
      t.timestamps
    end
    add_index :product_images, [:product_id, :position]
    add_index :product_images, [:product_id, :is_cover], unique: true, where: 'is_cover = true'
  end
end
