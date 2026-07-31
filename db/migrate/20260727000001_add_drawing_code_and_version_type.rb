class AddDrawingCodeAndVersionType < ActiveRecord::Migration[8.1]
  def change
    add_column :design_drawings, :drawing_code, :string
    add_index :design_drawings, :drawing_code, unique: true

    add_column :drawing_versions, :version_type, :string, default: 'draft'
    add_column :drawing_versions, :version_label, :string
    add_index :drawing_versions, :version_type
    add_index :drawing_versions, :version_label
  end
end
