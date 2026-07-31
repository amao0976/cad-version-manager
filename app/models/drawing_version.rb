class DrawingVersion < ApplicationRecord
  belongs_to :design_drawing
  belongs_to :uploaded_by, class_name: 'User'
  has_one_attached :file
  has_many :drawing_approvals, dependent: :destroy

  validates :version_label, presence: true
  validates :version_type, presence: true, inclusion: { in: %w[draft formal] }
  validates :version_label, uniqueness: { scope: [:design_drawing_id, :version_type] }
  validates :file, presence: true

  before_validation :generate_version_info, on: :create
  before_save :generate_file_path

  scope :drafts, -> { where(version_type: 'draft') }
  scope :formals, -> { where(version_type: 'formal') }
  scope :latest_first, -> { order(created_at: :desc) }

  def file_name
    file&.filename&.to_s
  end

  def file_url(expires_in: 1.hour)
    return nil unless file.attached?
    Rails.application.routes.url_helpers.rails_blob_url(file, expires_in: expires_in, only_path: false)
  end

  def is_latest?
    design_drawing.latest_version == self
  end

  def is_approved?
    drawing_approvals.exists?(status: 'approved')
  end

  def is_draft?
    version_type == 'draft'
  end

  def is_formal?
    version_type == 'formal'
  end

  def download_url
    file_url(expires_in: 24.hours)
  end

  def display_label
    if is_formal?
      "V#{version_label}"
    else
      version_label
    end
  end

  def display_version
    "#{version_type == 'formal' ? '正式' : '草稿'} #{display_label}"
  end

  def folder_path
    project = design_drawing.design_project
    drawing = design_drawing
    "#{sanitize_name(project.name)}/#{sanitize_name(drawing.name)}/#{display_label}"
  end

  def promote_to_formal!
    return if is_formal?
    next_letter = design_drawing.next_formal_letter
    update!(version_type: 'formal', version_label: next_letter, change_log: "#{change_log} | 升级为正式版本".strip)
  end

  private

  def generate_version_info
    if version_label.blank?
      if version_type == 'formal'
        self.version_label = design_drawing.next_formal_letter
      else
        self.version_label = design_drawing.next_draft_number
      end
    end
    self.version_number = "#{version_type == 'formal' ? 'V' : ''}#{version_label}"
  end

  def generate_file_path
    if file&.attached? && file.blob&.filename
      project = design_drawing.design_project
      drawing = design_drawing
      filename = file.blob.filename.to_s
      ext = File.extname(filename)
      sanitized_filename = File.basename(filename, ext)
      sanitized_filename = sanitize_name(sanitized_filename)

      new_filename = "#{sanitized_filename}_#{display_label}#{ext}"
      file.blob.update(filename: new_filename)
    end
  end

  def sanitize_name(name)
    name.to_s.strip.gsub(/[^a-zA-Z0-9_\u4e00-\u9fa5]/, '_').gsub(/_+/, '_')
  end
end
