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
  class Payload
    include EnvironmentVariables
    # Set bridge headers & env's.
    #
    # @param [Hash(String, String)] incoming_request
    # @param [Hash(String, String)] user_data
    # @param [ActiveRecord::Relation(EnvironmentVariable)] environment_variables
    def initialize(incoming_request, user_data, environment_variables)
      @incoming_request = incoming_request
      @user_data = user_data
      @environment_variables = environment_variables
    end

    # Parses the user's custom payload replacing any values containing `$env`
    # or `$payload` with the respective value
    #
    # @return [Hash(String, String)]
    def parse_payload
      parse_payload!

      outbound_request
    end

    private

    attr_reader :user_data,        # User defined payload (bridge.data['payload'])
                :outbound_request, # Parsed request returned from `parse_payload`
                :incoming_request, # Inbound request from service A
                :environment_variables

    # Iterates through user defined payload and parse values containing `$env` or `$payload`
    # Reinitializes & mutates `outbound_request`
    def parse_payload!
      @outbound_request = {} # Reset

      user_data.each do |key, val|
        outbound_request[key] = if val.include?('$env')
                                  fetch_environment_variable(val)
                                elsif val.include?('$payload')
                                  fetch_payload_data(val)
                                else
                                  val
                                end
      end
    end

    def fetch_payload_data(value)
      values = value.split('.')
      data = incoming_request # Set data to the incoming request

      values.each_with_index do |val, idx|
        next if idx.zero? # skip the $payload

        data = data[val] # dig deeper into the request on each iteration
        raise InvalidPayloadKey if data.nil?
      end

      data
    end
  end
end
