# frozen_string_literal: true

module BridgeApi
  module Http
    # Request handler is the main entry for our briding system. RequestHandler is the orchestrator
    # managing flow & all the different pieces.
    #
    # Example:
    #
    # ```ruby
    # event = Event.find(1)
    #
    # handler = BridgeApi::Http::Handler.new event
    # handler.execute
    #
    # event.complete! # => events `data` attribute was mutated setting data['outbound'] with
    # # {"request" => {request_data}, "response" => {response_from_server} }
    # ```
    #
    # ```ruby
    # # Setting custom `http_builder`
    # event = Event.find(1)
    #
    # handler = BridgeApi::Http::Handler.new event
    # handler.http_builder =
    #   XmlHttpBuilder.new handler, handler.payload_parser, handler.headers_parser
    #
    # handler.execute # => Will now use your XmlHttpBuilder class
    #
    # event.complete! # => events `data` attribute was mutated setting data['outbound'] with
    # # {"request" => {request_data}, "response" => {response_from_server} }
    # ```
    class Handler
      # Inject any piece of the request handling system for extending or testing.
      #
      # @param [BridgeApi::Http::Interfaces::Builder] http_builder
      # @param [BridgeApi::Http::Interfaces::Formatter] formatter
      # @param [BridgeApi::Http::Interfaces::Deconstructor] formatter
      # @param [BridgeApi::SyntaxParser::Interfaces::HeadersParser] headers_parser
      # @param [BridgeApi::SyntaxParser::Interfaces::PayloadParser] payload_parser
      attr_writer :http_builder,
                  :formatter,
                  :deconstructor,
                  :headers_parser,
                  :payload_parser

      attr_reader :event, :bridge

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

      # These next few methods are public for easy injection.
      # If you wanted to inject your own http_builder but keep everything
      # else as the default, that would be rather difficult without these
      # being public.

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

      private

      attr_reader :request

      # @return [BridgeApi::Http::Interfaces::Builder]
      def http_builder
        @http_builder ||= Builder.new self, payload_parser, headers_parser
      end

      # @return [BridgeApi::Http::Interfaces::Formatter]
      def formatter
        @formatter ||= Formatter.new deconstructor
      end
    end
  end
end
