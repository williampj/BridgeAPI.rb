# frozen_string_literal: true

require_relative './JWT/expired_web_token'

class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  # Expects a hash {user_id: id}
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY).first
    current = DateTime.now
    raise JWT::ExpiredWebToken if current > decoded['exp']

    decoded
  end
end
