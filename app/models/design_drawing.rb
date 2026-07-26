class DesignDrawing < ApplicationRecord
  belongs_to :design_project
  belongs_to :created_by, class_name: 'User'
  has_many :drawing_versions, dependent: :destroy
  has_many :drawing_approvals, dependent: :destroy
  has_many :product_boms, dependent: :destroy
  has_many :bom_items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :file_type, presence: true, inclusion: { in: ['prt', 'asm', 'dft', 'dwg', 'step', 'iges', 'stl', 'other'] }

  def self.file_types
    {
      prt: 'NX Part',
      asm: 'NX Assembly',
      dft: 'Solid Edge Draft',
      dwg: 'AutoCAD Drawing',
      step: 'STEP',
      iges: 'IGES',
      stl: 'STL',
      other: 'Other'
    }
  end

  def latest_version
    drawing_versions.order(created_at: :desc).first
  end

  def version_count
    drawing_versions.count
  end

  def approved_version
    drawing_approvals.where(status: 'approved').order(created_at: :desc).first&.drawing_version
  end
end
