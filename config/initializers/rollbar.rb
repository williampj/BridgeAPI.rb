# frozen_string_literal: true

require 'rollbar/logger'

Rails.logger.extend(ActiveSupport::Logger.broadcast(Rollbar::Logger.new))
