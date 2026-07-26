class CreateProductBoms < ActiveRecord::Migration[8.1]
  def change
    create_table :product_boms do |t|
      t.references :design_project, null: false, foreign_key: true
      t.references :design_drawing, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :revision, default: 'A'
      t.string :status, default: 'draft'
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end