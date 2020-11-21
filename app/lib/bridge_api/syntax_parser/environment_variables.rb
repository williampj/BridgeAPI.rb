# frozen_string_literal: true

module BridgeApi
  module SyntaxParser
    module EnvironmentVariables
      # Takes a value such as `$env.API_KEY`, finds the corresponding
      # EnvironmentVariable & returns the decrypted value.
      #
      # @param [String] value
      #
      # @return [String]
      def fetch_environment_variable(value)
        key = value.split('.').last
        environment_variable = environment_variables.find_by(key: key)
        raise ::InvalidEnvironmentVariable unless environment_variable

        environment_variable.decrypt
      end
    end
  end
end
