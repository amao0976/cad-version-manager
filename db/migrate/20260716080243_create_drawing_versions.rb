class CreateDrawingVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :drawing_versions do |t|
      t.references :design_drawing, null: false, foreign_key: true
      t.string :version_number
      t.text :change_log
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.integer :file_size

      t.timestamps
    end
    add_index :drawing_versions, :version_number
  end
end
