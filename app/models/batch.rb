class Batch < ApplicationRecord
  belongs_to :product
  belongs_to :variant
  has_many :serial_numbers, dependent: :nullify

  before_validation :set_product_from_variant, on: :create

  validates :number, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: ['in_production', 'in_stock', 'sold_out', 'scrapped'] }

  private

  def set_product_from_variant
    self.product = variant.product if variant && product.nil?
  end

  def self.statuses
    { in_production: 'in_production', in_stock: 'in_stock', sold_out: 'sold_out', scrapped: 'scrapped' }
  end

  def receive_stock(qty)
    self.quantity += qty
    self.status = 'in_stock'
    save
  end

  def fully_serialized?
    serial_numbers.count >= quantity
  end
end
