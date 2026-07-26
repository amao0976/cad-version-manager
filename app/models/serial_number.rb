class SerialNumber < ApplicationRecord
  belongs_to :variant
  belongs_to :batch, optional: true

  validates :code, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :status, presence: true, inclusion: { in: ['in_stock', 'sold', 'returned', 'scrapped'] }

  scope :in_stock, -> { where(status: 'in_stock') }
  scope :sold, -> { where(status: 'sold') }

  def self.statuses
    { in_stock: 'in_stock', sold: 'sold', returned: 'returned', scrapped: 'scrapped' }
  end

  def sell
    update(status: 'sold', sold_at: Time.current)
  end

  def return_item
    update(status: 'returned')
  end

  def scrap
    update(status: 'scrapped')
  end
end
