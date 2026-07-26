class Material < ApplicationRecord
  has_many :material_prices, dependent: :destroy
  has_many :products, foreign_key: 'main_material_id'
  has_many :variants

  validates :name, presence: true, length: { maximum: 100 }
  validates :code, presence: true, uniqueness: true, length: { maximum: 50 }

  def current_price
    material_prices.order(effective_date: :desc).first&.price_per_unit
  end

  def price_on(date)
    material_prices.where('effective_date <= ?', date).order(effective_date: :desc).first&.price_per_unit
  end
end
