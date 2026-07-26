class MaterialPrice < ApplicationRecord
  belongs_to :material

  validates :effective_date, presence: true, uniqueness: { scope: :material_id }
  validates :price_per_unit, presence: true, numericality: { greater_than: 0 }

  default_scope { order(effective_date: :desc) }
end
