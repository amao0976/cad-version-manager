class AddWatchCategoryFieldsToProductsAndMaterials < ActiveRecord::Migration[8.1]
  def change
    # 为产品添加机芯、表带类型、目标人群分类字段
    add_reference :products, :movement_category, foreign_key: { to_table: :categories }
    add_reference :products, :strap_category, foreign_key: { to_table: :categories }
    add_reference :products, :target_group_category, foreign_key: { to_table: :categories }

    # 为材质（零件/配件）添加表壳材质分类字段
    add_reference :materials, :case_material_category, foreign_key: { to_table: :categories }
  end
end
