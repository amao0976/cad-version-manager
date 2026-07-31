require 'jwt'

class JwtService
  ALGORITHM = 'HS256'
  EXPIRATION = 2.weeks

  def self.encode(payload, expiration = EXPIRATION.from_now)
    payload = payload.dup
    payload[:exp] = expiration.to_i
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
    decoded.first
  rescue JWT::DecodeError => e
    raise JWT::DecodeError, 'Invalid token'
  end

  def self.secret_key
    Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE']
  end
end
