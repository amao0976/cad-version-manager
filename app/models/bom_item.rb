class BomItem < ApplicationRecord
  belongs_to :product_bom
  belongs_to :design_drawing, optional: true
  belongs_to :parent, class_name: 'BomItem', optional: true
  belongs_to :color, optional: true
  has_many :sub_items, class_name: 'BomItem', foreign_key: 'parent_id', dependent: :destroy

  validates :part_number, presence: true, length: { maximum: 100 }
  validates :part_name, presence: true, length: { maximum: 255 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :level, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :source, presence: true, inclusion: { in: ['in_house', 'purchased', 'outsourced', 'borrowed'] }

  def self.sources
    { in_house: '自制', purchased: '外购', outsourced: '外协', borrowed: '借用' }
  end

  def has_sub_items?
    sub_items.any?
  end

  def full_part_number
    "#{product_bom&.name}-#{part_number}"
  end
end