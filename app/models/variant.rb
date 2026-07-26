class Variant < ApplicationRecord
  belongs_to :product
  belongs_to :material, optional: true
  has_many :batches, dependent: :destroy
  has_many :serial_numbers, dependent: :destroy

  validates :sku_code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :status, presence: true, inclusion: { in: ['active', 'inactive'] }

  def self.statuses
    { active: 'active', inactive: 'inactive' }
  end

  def effective_weight
    weight.presence || product.base_weight
  end

  def current_price
    PriceCalculator.calculate(self)
  end
end
