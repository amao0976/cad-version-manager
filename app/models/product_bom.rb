class ProductBom < ApplicationRecord
  belongs_to :design_project
  belongs_to :design_drawing, optional: true
  belongs_to :product, optional: true
  belongs_to :created_by, class_name: 'User'
  has_many :bom_items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :revision, presence: true
  validates :status, presence: true, inclusion: { in: ['draft', 'approved', 'released', 'archived'] }

  def self.statuses
    { draft: 'draft', approved: 'approved', released: 'released', archived: 'archived' }
  end

  def total_items
    bom_items.count
  end

  def total_quantity
    bom_items.sum(:quantity)
  end

  def total_weight
    bom_items.sum(:weight) || 0
  end

  def child_items
    bom_items.where(parent_id: nil)
  end

  def approve
    update(status: 'approved')
  end

  def release
    update(status: 'released')
  end

  def archive
    update(status: 'archived')
  end
end