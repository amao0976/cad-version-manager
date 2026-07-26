class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :products

  validates :name, presence: true, length: { maximum: 100 }
  validates :code, length: { maximum: 50 }

  def full_path
    if parent
      "#{parent.full_path} / #{name}"
    else
      name
    end
  end

  # 计算分类层级深度（顶级=1）
  def level
    parent ? parent.level + 1 : 1
  end

  # 获取自身及所有子分类的ID列表
  def self_and_descendants
    [id] + children.map(&:id)
  end
end
