class CreateDesignProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :design_projects do |t|
      t.string :name
      t.text :description
      t.string :status
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :design_projects, :status
  end
end
