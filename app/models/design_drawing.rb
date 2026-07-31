class DesignDrawing < ApplicationRecord
  belongs_to :design_project
  belongs_to :created_by, class_name: 'User'
  has_many :drawing_versions, dependent: :destroy
  has_many :drawing_approvals, dependent: :destroy
  has_many :product_boms, dependent: :destroy
  has_many :bom_items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :file_type, presence: true, inclusion: { in: ['prt', 'asm', 'dft', 'dwg', 'step', 'iges', 'stl', 'other'] }
  validates :drawing_code, uniqueness: true, allow_blank: true

  before_validation :generate_drawing_code, on: :create

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

  def latest_draft
    drawing_versions.drafts.order(created_at: :desc).first
  end

  def latest_formal
    drawing_versions.formals.order(created_at: :desc).first
  end

  def version_count
    drawing_versions.count
  end

  def approved_version
    drawing_approvals.where(status: 'approved').order(created_at: :desc).first&.drawing_version
  end

  def next_draft_number
    last_draft = drawing_versions.drafts.order(created_at: :desc).first
    if last_draft&.version_label
      (last_draft.version_label.to_i + 1).to_s.rjust(2, '0')
    else
      '00'
    end
  end

  def next_formal_letter
    last_formal = drawing_versions.formals.order(created_at: :desc).first
    if last_formal&.version_label
      (last_formal.version_label.succ)
    else
      'A'
    end
  end

  def display_drawing_code
    drawing_code || "DWG-#{id.to_s.rjust(4, '0')}"
  end

  private

  def generate_drawing_code
    if drawing_code.blank?
      prefix = 'DWG'
      seq = (DesignDrawing.maximum(:id) || 0) + 1
      self.drawing_code = "#{prefix}-#{seq.to_s.rjust(4, '0')}"
    end
  end
end
