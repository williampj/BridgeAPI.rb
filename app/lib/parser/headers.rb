# frozen_string_literal: true

# This class parses user defined headers & payloads into the values we expect
# to send to the outbound service.
#
# Example:
#
# ```ruby
# custom_user_payload = {
#   'hello' => '$payload.top_level_key',
#   'environment_variable' => '$env.API_KEY',
#   'did_you' => '$payload.nested_key_1.nested_key_2.nested_key_3'
# }
#
# incoming_request_from_service_a = {
#   'top_level_key' => 'world',
#   'nested_key_1' => {
#     'nested_key_2' => {
#       'nested_key_3' => 'make it!'
#     }
#   }
# }
#
# bridge = Bridge.where(user_id: @current_user.id)
#
# syntax_parser = SyntaxParser.new(bridge)
#
# syntax_parser.parse_payload(
#  incoming_request_from_service_a,
#  custom_user_payload
# ) # => Hash(String, String) where $payload & $env are replaced with their respective values
#
# syntax_parser.parse_headers # => Array(Hash(String, String)) where $env is
# replaced with decrypted environment variable value
# ```
module Parser
  class Headers
    include EnvironmentVariables
    # Set headers
    #
    # @param [ActiveRecord::Relation(Header)] environment_variables
    # @param [ActiveRecord::Relation(EnvironmentVariable)] environment_variables
    def initialize(headers, environment_variables)
      @headers = headers
      @environment_variables = environment_variables
    end

    # Parses the user's headers replacing any values containing `$env`
    # with the decrypted environment variable value
    #
    # @return [Array(Hash(String, String))]
    def parse_headers
      parse_headers!

      outbound_headers
    end

    private

    attr_reader :outbound_headers, # Parsed headers returned from `parse_headers`
                :environment_variables,
                :headers

    # Iterates through user defined payload and parse values containing `$env`
    # Reinitializes & mutates `outbound_headers`
    def parse_headers!
      @outbound_headers = [] # Reset
      headers.each do |header|
        parsed_header = {}
        parsed_header[header.key] = if header.value.include?('$env')
                                      fetch_environment_variable(header.value)
                                    else
                                      header.value
                                    end

        outbound_headers << parsed_header
      end
    end

    def fetch_environment_variable(value)
      key = value.split('.').last
      environment_variable = environment_variables.where(key: key)
      raise InvalidEnvironmentVariable unless environment_variable

      environment_variable.decrypt
    end
  end
end
