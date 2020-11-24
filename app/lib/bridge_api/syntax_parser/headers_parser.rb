# frozen_string_literal: true

module BridgeApi
  module SyntaxParser
    # This class parses user defined headers & payloads into the values we expect
    # to send to the outbound service.
    #
    # Example:
    #
    # ```ruby
    # request = Net::Http::Post.new URI('http://example.com/index.html?count=10')
    #
    # bridge = Bridge.where(user_id: @current_user.id)
    #
    # headers_parser = BridgeApi::SyntaxParser::HeadersParser.new bridge.environment_variables
    #
    # headers_parser.parse(bridge.headers) do |key, value|
    #   request[key] = value
    # end
    # ```
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
      # @param [Proc] block
      #
      # @return [Array(Hash(String, String))]
      def parse(headers, &block)
        @headers = headers
        parse_headers!(block)
      end

      private

      attr_reader :environment_variables,
                  :headers

      # Iterates over headers, yields to a block passing in the header key &
      # parsed value if parsing is required.
      #
      # @param [Proc] block
      def parse_headers!(block)
        headers.each { |header| block.call(header.key, parse_value(header.value)) }
      end

      # Replaces a `$env.API_KEY` string with the decrypted
      # EnvironmentVariable value.
      #
      # @param [String] value
      #
      # @return [String]
      def parse_value(value)
        if value.include?('$env')
          fetch_environment_variable(value)
        else
          value
        end
      end
    end
  end
end
