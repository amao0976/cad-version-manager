class AddProductToProductBoms < ActiveRecord::Migration[8.1]
  def change
    add_reference :product_boms, :product, null: true, foreign_key: true
  end
end
