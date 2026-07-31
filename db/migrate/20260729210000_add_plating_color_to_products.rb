class AddPlatingColorToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :plating_color, :string, comment: '电镀颜色，如：金色、玫瑰金、银色、铑色、黑铑、枪色、古铜色等'
  end
end
