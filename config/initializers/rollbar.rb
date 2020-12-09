# frozen_string_literal: true

require 'rollbar/logger'

class NoRollbarToken < StandardError
end

raise NoRollbarToken if Rails.env == 'production' && !ENV['ROLLBAR_ACCESS_TOKEN']

Rails.logger.extend(ActiveSupport::Logger.broadcast(Rollbar::Logger.new))
