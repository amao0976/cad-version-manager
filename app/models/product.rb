class Product < ApplicationRecord
  belongs_to :category
  belongs_to :design_drawing, optional: true
  belongs_to :main_material, class_name: 'Material', optional: true
  has_many :variants, dependent: :destroy
  has_many :product_boms, dependent: :nullify
  has_many :batches, through: :variants
  has_many :serial_numbers, through: :variants

  validates :name, presence: true, length: { maximum: 255 }
  validates :product_code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :status, presence: true, inclusion: { in: ['draft', 'published', 'offline'] }

  def self.statuses
    { draft: 'draft', published: 'published', offline: 'offline' }
  end

  def publish
    update(status: 'published')
  end

  def offline
    update(status: 'offline')
  end

  def default_variant
    variants.first
  end
end
