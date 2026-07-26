class DrawingVersion < ApplicationRecord
  belongs_to :design_drawing
  belongs_to :uploaded_by, class_name: 'User'
  has_one_attached :file
  has_many :drawing_approvals, dependent: :destroy

  validates :version_number, presence: true, uniqueness: { scope: :design_drawing_id }
  validates :file, presence: true

  before_validation :generate_version_number, on: :create
  before_save :generate_file_path

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

  def download_url
    file_url(expires_in: 24.hours)
  end

  def folder_path
    project = design_drawing.design_project
    drawing = design_drawing
    "#{sanitize_name(project.name)}/#{sanitize_name(drawing.name)}/v#{version_number}"
  end

  private

  def generate_version_number
    return if version_number.present?
    last_version = design_drawing.drawing_versions.order(created_at: :desc).first
    if last_version
      major, minor = last_version.version_number.split('.').map(&:to_i)
      self.version_number = "#{major}.#{minor + 1}"
    else
      self.version_number = '1.0'
    end
  end

  def generate_file_path
    if file&.attached? && file.blob&.filename
      project = design_drawing.design_project
      drawing = design_drawing
      filename = file.blob.filename.to_s
      ext = File.extname(filename)
      sanitized_filename = File.basename(filename, ext)
      sanitized_filename = sanitize_name(sanitized_filename)
      
      new_filename = "#{sanitized_filename}_v#{version_number}#{ext}"
      file.blob.update(filename: new_filename)
    end
  end

  def sanitize_name(name)
    name.to_s.strip.gsub(/[^a-zA-Z0-9_\u4e00-\u9fa5]/, '_').gsub(/_+/, '_')
  end
end