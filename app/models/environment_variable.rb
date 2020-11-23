# frozen_string_literal: true

class EnvironmentVariable < ApplicationRecord
  validates :key, presence: true
  validates :value, presence: true

  belongs_to :bridge

  before_save :encrypt, if: proc { |c| c.value_changed? }

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  KEY = ActiveSupport::KeyGenerator.new(
    ENV.fetch('SECRET_KEY_BASE') || Rails.application.secrets.secret_key_base
  ).generate_key(
    ENV.fetch('ENCRYPTION_KEY_SALT'),
    ActiveSupport::MessageEncryptor.key_len
  ).freeze

  private_constant :KEY

  def decrypt
    decrypt_and_verify(value)
  end

  private

  def encrypt
    self.value = encrypt_and_sign(value)
  end

  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end
