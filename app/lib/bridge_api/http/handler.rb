# frozen_string_literal: true

module BridgeApi
  module Http
    # TODO
    class Handler
      # Inject a different builder, formatter or deconstructor
      #
      # @param [BridgeApi::Http::Interfaces::Builder] http_builder
      attr_writer :http_builder,
                  # @param [BridgeApi::Http::Interfaces::Formatter] formatter
                  :formatter,
                  # @param [BridgeApi::Http::Interfaces::Deconstructor] formatter
                  :deconstructor

      # @param [Event] event
      def initialize(event)
        @event = event
        @bridge = @event.bridge
      end

      # Handles building and sending a HTTP request and then
      # formats and stores the data into event object.
      def execute
        net_http, @request = http_builder.generate
        response = net_http.request request
        formatter.format! event, request, response

        raise Sidekiq::LargeStatusCode if response.code.to_i >= 300
      end

      # Handles storing the request & error into the event data
      def cleanup(error)
        formatter.format_error! event, request, error
      end

      private

      attr_accessor :event,
                    :bridge,
                    :request

      # @return [BridgeApi::Http::Interfaces::Builder]
      def http_builder
        @http_builder ||= Builder.new bridge, event.test, payload_parser, headers_parser
      end

      # @return [BridgeApi::Http::Interfaces::Formatter]
      def formatter
        @formatter ||= Formatter.new deconstructor
      end

      # @return [BridgeApi::Http::Interfaces::Deconstructor]
      def deconstructor
        @deconstructor ||= Deconstructor.new bridge.headers
      end

      # @return [BridgeApi::SyntaxParser::Interfaces::HeadersParser]
      def headers_parser
        @headers_parser ||= SyntaxParser::HeadersParser.new bridge.environment_variables
      end

      # @return [BridgeApi::SyntaxParser::Interfaces::PayloadParser]
      def payload_parser
        @payload_parser ||= SyntaxParser::PayloadParser.new bridge.environment_variables
      end
    end
  end
end
