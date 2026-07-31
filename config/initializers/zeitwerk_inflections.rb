# Configure Zeitwerk inflections for non-standard naming
# This ensures Zeitwerk can map file names to class names correctly

Rails.autoloaders.main.inflector.inflect(
  "web_dav_storage_service" => "WebDAVStorageService",
  "web_dav" => "WebDAV"
)
