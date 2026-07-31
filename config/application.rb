require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CadVersionManager
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])
    config.autoload_paths << Rails.root.join('app', 'uploaders')
    config.eager_load_paths << Rails.root.join('app', 'uploaders')

    # Configure Zeitwerk inflections for non-standard naming
    config.autoloaders.main.inflector.inflect(
      "web_dav_storage_service" => "WebDAVStorageService"
    )

    # Ensure middleware stack is configured correctly
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_cad_version_manager_session'

    # Disable turbo by default for forms to avoid issues with Devise
    config.turbo.forms = :off
  end
end
