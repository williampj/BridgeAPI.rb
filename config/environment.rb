# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ENV['ENCRYPTION_SERVICE_SALT'] = Rails.application.credentials[:ENCRYPTION_SERVICE_SALT]
