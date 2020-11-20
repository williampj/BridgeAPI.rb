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
module BridgeApi
  module SyntaxParser
    # TODO: Doc
    class HeadersParser
      include EnvironmentVariables
      include Interfaces::HeadersParser

      # @param [ActiveRecord::Relation(EnvironmentVariable)] environment_variables
      def initialize(environment_variables)
        @environment_variables = environment_variables
      end

      # Handles parsing the user's headers replacing any values containing `$env`
      # with the decrypted environment variable value. Expected to be invoked
      # with a block. The block will be called on each iteration of a header passing
      # in `header.key` & a parsed version of `header.value` as arguments.
      #
      # @param [ActiveRecord::Relation(Header)] environment_variables
      #
      # @return [Array(Hash(String, String))]
      def parse(headers, &block)
        @headers = headers
        parse_headers!(block)
      end

      private

      attr_reader :environment_variables,
                  :headers

      # TODO: Doc
      def parse_headers!(block)
        headers.each { |header| block.call(header.key, safe_value(header.value)) }
      end

      # TODO: Doc
      def safe_value(value)
        if value.include?('$env')
          fetch_environment_variable(value)
        else
          value
        end
      end
    end
  end
end
