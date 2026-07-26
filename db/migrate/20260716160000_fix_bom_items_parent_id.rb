class FixBomItemsParentId < ActiveRecord::Migration[8.1]
  def change
    remove_reference :bom_items, :parent_id
    add_reference :bom_items, :parent, foreign_key: { to_table: :bom_items }
  end
end