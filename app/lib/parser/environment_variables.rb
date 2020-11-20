# frozen_string_literal: true

module Parser
  module EnvironmentVariables
    # TODO
    def fetch_environment_variable(value)
      key = value.split('.').last
      environment_variable = environment_variables.where(key: key)
      raise InvalidEnvironmentVariable unless environment_variable

      environment_variable.decrypt
    end
  end
end
