require "active_storage/service"
require "webdav"

class WebDavStorageService < ActiveStorage::Service
  def initialize(url:, username:, password:, folder_structure: "project_drawing_version")
    @url = url
    @username = username
    @password = password
    @folder_structure = folder_structure
  end

  def upload(key, io, checksum: nil, content_type: nil, filename: nil, content_length: nil)
    ensure_connection

    directory = File.dirname(key)
    unless directory.empty? || directory == "."
      path = "/#{directory}"
      begin
        @client.mkcol(path)
      rescue Webdav::HTTPError => e
        unless e.message.include?("405")
          raise
        end
      end
    end

    io.rewind
    @client.put("/#{key}", body: io.read, content_type: content_type || "application/octet-stream")
  end

  def download(key)
    ensure_connection
    response = @client.get("/#{key}")
    StringIO.new(response.body)
  end

  def download_chunk(key, range)
    ensure_connection
    response = @client.get("/#{key}", headers: { "Range" => "bytes=#{range.begin}-#{range.exclude_end? ? range.end - 1 : range.end}" })
    StringIO.new(response.body)
  end

  def delete(key)
    ensure_connection
    @client.delete("/#{key}")
  rescue Webdav::HTTPError => e
    return if e.message.include?("404")
    raise
  end

  def delete_prefixed(prefix)
    ensure_connection
    response = @client.propfind("/#{prefix}", depth: "infinity")
    response.resources.reverse.each do |resource|
      href = resource[:href]
      next if href == "/#{prefix}" || href.end_with?("/")
      @client.delete(href)
    end
    @client.delete("/#{prefix}")
  rescue Webdav::HTTPError => e
    return if e.message.include?("404")
    raise
  end

  def exist?(key)
    ensure_connection
    response = @client.propfind("/#{key}", depth: "0")
    response.resources.any?
  rescue Webdav::HTTPError => e
    return false if e.message.include?("404")
    raise
  end

  def url(key, expires_in:, filename:, disposition:, content_type:)
    filename = ActiveStorage::Filename.wrap(filename).sanitized
    if Rails.application.routes.default_url_options[:host].present?
      Rails.application.routes.url_helpers.rails_service_blob_url(
        key,
        filename: filename,
        host: Rails.application.routes.default_url_options[:host]
      )
    else
      "#{@url}/#{key}"
    end
  end

  def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:, filename:)
    "#{@url}/#{key}"
  end

  def headers_for_direct_upload(key, filename:, content_type:, content_length:, checksum:)
    {}
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

  def ensure_connection
    return if @client

    @client = Webdav.new(@url, username: @username, password: @password)
  end

  def sanitize_name(name)
    name.to_s.strip.gsub(/[^a-zA-Z0-9_\u4e00-\u9fa5]/, '_').gsub(/_+/, '_')
  end
end