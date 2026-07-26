class CreateDesignDrawings < ActiveRecord::Migration[8.1]
  def change
    create_table :design_drawings do |t|
      t.references :design_project, null: false, foreign_key: true
      t.string :name
      t.string :file_type
      t.text :description
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :design_drawings, :file_type
  end
end
