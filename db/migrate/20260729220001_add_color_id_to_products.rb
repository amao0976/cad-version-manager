class AddColorIdToProducts < ActiveRecord::Migration[8.1]
  def change
    add_reference :products, :color, index: true
  end
end
