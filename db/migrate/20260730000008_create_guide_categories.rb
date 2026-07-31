class CreateGuideCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :guide_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :sort_order, default: 0
      t.timestamps
    end
    add_index :guide_categories, :slug, unique: true
  end
end
