class CreateDrawingApprovals < ActiveRecord::Migration[8.1]
  def change
    create_table :drawing_approvals do |t|
      t.references :design_drawing, null: false, foreign_key: true
      t.references :drawing_version, null: false, foreign_key: true
      t.references :approver, null: false, foreign_key: { to_table: :users }
      t.string :status
      t.text :comment

      t.timestamps
    end
    add_index :drawing_approvals, :status
  end
end
