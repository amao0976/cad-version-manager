# CORS configuration for API access
# In production on Railway, set FRONTEND_URL env var to allow frontend domain

allowed_origins = [
  # Development
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:8081',
  'http://localhost:19000',
  'http://localhost:19001',
  'http://localhost:5000',
  'http://localhost:8000',
  # Mobile device access
  'http://10.0.2.2:3000',
  'http://10.0.2.2:5173',
  'http://10.0.2.2:19000',
  'http://192.168.1.100:3000',
  'http://192.168.1.100:5173',
]

# Add production frontend URL if configured (Railway deployment)
if ENV['FRONTEND_URL'].present?
  allowed_origins << ENV['FRONTEND_URL']
  # Also allow www subdomain if not already included
  uri = URI.parse(ENV['FRONTEND_URL'])
  if uri.host.present? && !uri.host.start_with?('www.')
    allowed_origins << "#{uri.scheme}://www.#{uri.host}#{uri.port ? ":#{uri.port}" : ''}"
  end
end

# Allow all Railway domains (matches *.up.railway.app and *.railway.app)
allowed_origins << /\.up\.railway\.app$/
allowed_origins << /\.railway\.app$/

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins allowed_origins

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization', 'X-Total-Count', 'X-Page', 'X-Per-Page'],
      credentials: true
  end
end
