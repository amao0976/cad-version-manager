class AddThemeToProductsAndColorToBomItems < ActiveRecord::Migration[8.1]
  def change
    # 为products表添加theme字段
    add_column :products, :theme, :string, comment: '产品主题，如：金色主题、银色主题等'
    add_index :products, :theme

    # 为bom_items表添加color_id关联
    add_reference :bom_items, :color, index: true
  end
end