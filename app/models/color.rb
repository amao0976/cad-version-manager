class Color < ApplicationRecord
  has_many :products

  validates :name, presence: true, length: { maximum: 100 }
  validates :code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :color_type, presence: true, inclusion: { in: %w[plating fabric_leather other] }

  scope :active, -> { where(active: true) }
  scope :plating, -> { where(color_type: 'plating') }
  scope :fabric_leather, -> { where(color_type: 'fabric_leather') }
  scope :other, -> { where(color_type: 'other') }

  def self.color_types
    {
      '电镀颜色' => 'plating',
      '布料皮料颜色' => 'fabric_leather',
      '其他颜色' => 'other'
    }
  end

  def color_type_label
    self.class.color_types.key(color_type) || color_type
  end
end
