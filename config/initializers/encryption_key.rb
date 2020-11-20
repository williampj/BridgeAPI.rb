# frozen_string_literal: true

class NoEncryptionKey < StandardError
end

# The ENCRYPTION_KEY_SALT environment variable is hard coded for test and dev environments
# but expected to be set in production

if Rails.env == 'test' || Rails.env == 'development'
  # rubocop:disable Layout/LineLength
  ENV['ENCRYPTION_KEY_SALT'] = "e4l\xB7\x98p\xE3\x97\xE4H[\xE8\x8A\xFF\xC5\x11\xF8\xB7\x05\x95Oj\x9CS\x8A\x8A\fF\x90:\xE0\xFB"
  # rubocop:enable Layout/LineLength
end

raise NoEncryptionKey if Rails.env == 'production' && !ENV['ENCRYPTION_KEY_SALT']
