class DesignProject < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  has_many :design_drawings, dependent: :destroy
  has_many :product_boms, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: ['active', 'completed', 'archived'] }

  def self.statuses
    { active: 'active', completed: 'completed', archived: 'archived' }
  end

  def latest_drawings
    design_drawings.order(updated_at: :desc).limit(10)
  end
end
