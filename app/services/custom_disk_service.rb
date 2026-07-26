require "active_storage/service/disk_service"

class CustomDiskService < ActiveStorage::Service::DiskService
  def initialize(root:, folder_structure: "project_drawing_version")
    super(root: root)
    @folder_structure = folder_structure
  end

  def upload(key, io, checksum: nil, content_type: nil, filename: nil, content_length: nil)
    super(key, io, checksum: checksum, content_type: content_type, filename: filename, content_length: content_length)
  end

  def path_for(key)
    File.join(root, key)
  end

  def url(key, expires_in:, filename:, disposition:, content_type:)
    filename = ActiveStorage::Filename.wrap(filename).sanitized
    if Rails.application.routes.default_url_options[:host].present?
      Rails.application.routes.url_helpers.rails_disk_service_url(key, filename: filename, host: Rails.application.routes.default_url_options[:host])
    else
      "/rails/active_storage/disk/#{encoded_key(key)}/#{filename}"
    end
  end

  def generate_key(drawing_version)
    project = drawing_version.design_drawing.design_project
    drawing = drawing_version.design_drawing
    sanitized_project_name = sanitize_name(project.name)
    sanitized_drawing_name = sanitize_name(drawing.name)
    filename = drawing_version.file_name || "drawing"
    ext = File.extname(filename)
    sanitized_filename = sanitize_name(File.basename(filename, ext))
    
    case @folder_structure
    when "project_drawing_version"
      "#{sanitized_project_name}/#{sanitized_drawing_name}/v#{drawing_version.version_number}/#{sanitized_filename}_v#{drawing_version.version_number}#{ext}"
    when "project_drawing"
      "#{sanitized_project_name}/#{sanitized_drawing_name}/#{sanitized_filename}_v#{drawing_version.version_number}#{ext}"
    when "drawing_version"
      "#{sanitized_drawing_name}/v#{drawing_version.version_number}/#{sanitized_filename}_v#{drawing_version.version_number}#{ext}"
    else
      "#{sanitized_project_name}/#{sanitized_drawing_name}/v#{drawing_version.version_number}/#{sanitized_filename}_v#{drawing_version.version_number}#{ext}"
    end
  end

  private

  def sanitize_name(name)
    name.to_s.strip.gsub(/[^a-zA-Z0-9_\u4e00-\u9fa5]/, '_').gsub(/_+/, '_')
  end

  def encoded_key(key)
    Base64.urlsafe_encode64(key)
  end
end