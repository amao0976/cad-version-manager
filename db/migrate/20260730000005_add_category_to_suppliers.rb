class AddCategoryToSuppliers < ActiveRecord::Migration[8.1]
  def change
    add_column :suppliers, :category, :string, limit: 100
  end
end
