# frozen_string_literal: true

module BridgeApi
  module SyntaxParser
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
    # incoming_payload_from_service_a = {
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
    # payload_parser = BridgeApi::SyntaxParser::PayloadParser.new bridge.environment_variables
    #
    # payload_parser.parse(
    #  incoming_payload_from_service_a,
    #  custom_user_payload
    # ) # => Hash(String, String) where $payload & $env are replaced with their respective values
    # ```
    class PayloadParser
      include EnvironmentVariables
      include Interfaces::PayloadParser

      # @param [ActiveRecord::Relation(EnvironmentVariable)] environment_variables
      def initialize(environment_variables)
        @environment_variables = environment_variables
      end

      # Parses the user's custom payload replacing any values containing `$env`
      # or `$payload` with the respective value
      #
      # @param [Hash(String, String)] incoming_payload
      # @param [Hash(String, String)] user_data
      #
      # @return [Hash(String, String)]
      def parse(incoming_payload, user_data)
        @incoming_payload = incoming_payload
        @user_data = user_data
        parse_payload!

        outbound_payload
      end

      private

      attr_reader :user_data,        # User defined payload (bridge.data['payload'])
                  :outbound_payload, # Parsed request returned from `parse_payload`
                  :incoming_payload, # Inbound payload from service A
                  :environment_variables

      # Iterates through user defined payload and parse values containing `$env` or `$payload`
      # Reinitializes & mutates `outbound_payload`
      def parse_payload!
        @outbound_payload = {} # Reset

        user_data.each do |key, val|
          outbound_payload[key] = if val.include?('$env')
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
        data = incoming_payload # Set data to the incoming request

        values.each_with_index do |val, idx|
          next if idx.zero? # skip the $payload

          data = data[val.to_s] || data[val.to_sym] # dig deeper into the request on each iteration
          raise ::InvalidPayloadKey if data.nil?
        end

        data
      end
    end
  end
end
