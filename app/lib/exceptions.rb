# frozen_string_literal: true

class InvalidPayloadKey < StandardError
end

class InvalidEnvironmentVariable < StandardError
end

module JWT
  class ExpiredWebToken < StandardError
  end
end
