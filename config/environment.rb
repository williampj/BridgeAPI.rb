# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'
# For Rollbar monitoring of the Rails boot process
require_relative 'rollbar'

ENV['ENCRYPTION_SERVICE_SALT'] = Rails.application.credentials[:ENCRYPTION_SERVICE_SALT]

notify = lambda do |e|
  Rollbar.with_config(use_async: false) do
    Rollbar.error(e)
  end
rescue StandardError
  Rails.logger.error 'Synchronous Rollbar notification failed.  Sending async to preserve info'
  Rollbar.error(e)
end

# rubocop:disable Lint/RescueException
begin
  # Initialize the Rails application.
  Rails.application.initialize!
rescue Exception => e
  notify.call(e)
  raise
end
# rubocop:enable Lint/RescueException
