class PriceRule < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :material, optional: true

  validates :name, presence: true, length: { maximum: 100 }
  validates :markup_rate, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  def self.match_for(variant)
    category_id = variant.product&.category_id
    material_id = variant.material_id || variant.product&.main_material_id
    today = Date.current

    active_rules = active.where('effective_from <= ? AND (effective_to IS NULL OR effective_to >= ?)', today, today)

    rule = active_rules.find_by(category_id: category_id, material_id: material_id)
    return rule if rule

    rule = active_rules.find_by(category_id: category_id, material_id: nil)
    return rule if rule

    rule = active_rules.find_by(category_id: nil, material_id: material_id)
    return rule if rule

    active_rules.find_by(category_id: nil, material_id: nil)
  end
end
