# frozen_string_literal: true

module BridgeApi
  module Http
    # Handles building a HTTP Request object. Will parse user defined payloads
    # and headers into expected values. Accepts custom parsers for extending.
    #
    # Example:
    #
    # ```ruby
    # event = Event.find(1)
    #
    # handler = BridgeApi::Http::RequestHandler.new event
    # builder = BridgeApi::Http::Builder.new handler, handler.payload_parser, handler.headers_parser
    #
    # builder.generate # => returns an Tuple containing Net::Http & Net::Http::{user_request_type} objects
    # ```
    class Builder
      SCHEME = 'https://'

      include Interfaces::Builder

      # @param [BridgeApi::Http::Handler] request_handler - Used for delegation
      # @param [BridgeApi::SyntaxParser::Interfaces::PayloadParser] payload_parser
      # @param [BridgeApi::SyntaxParser::Interfaces::HeadersParser] headers_parser
      def initialize(request_handler, payload_parser, headers_parser)
        @request_handler = request_handler
        @payload_parser = payload_parser
        @headers_parser = headers_parser
      end

      # Generate & return `Net::HTTP`(net_http) & `Net::HTTP::{http_method}`(http_request) objects
      #
      # @return [Tuple(Net::HTTP, Net::HTTP::{http_method})]
      def generate
        [net_http, http_request]
      end

      private

      delegate :bridge, to: :request_handler
      delegate :event, to: :request_handler

      attr_reader :request,
                  :request_handler,
                  :payload_parser,
                  :headers_parser

      def net_http
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        http
      end

      def http_request
        @request = net_http_request
        parse_headers!
        request.body = parsed_payload.to_json

        request
      end

      # Convert user defined outbound_url into a valid URI
      #
      # @return [String]
      def uri
        @uri ||= URI(scheme)
      end

      # Sets the user defined headers into the `request` object
      def parse_headers!
        headers_parser.parse(headers) do |key, value|
          request[key] = value
        end
      end

      # Parse our custom syntax into the expected values
      #
      # @return [Hash(String, String)]
      def parsed_payload
        @parsed_payload ||= payload_parser.parse(
          event.inbound_payload,
          JSON.parse(unparsed_payload)
        )
      end

      # Returns either payload or test_payload depending
      # on the event environment
      #
      # @return [JSON]
      def unparsed_payload
        @unparsed_payload ||= data[test_env? ? 'test_payload' : 'payload']
      end

      # Ensures the scheme used is using TSL
      #
      # @return [String]
      def scheme
        return outbound_url if outbound_url.starts_with?('https')

        "#{SCHEME}#{outbound_url.split('//').last}"
      end

      # Create a HTTP request object based on the user defined
      # HTTP method.
      #
      # @return [Net::HTTP::{http_method}]
      def net_http_request
        "Net::HTTP::#{http_method}".constantize.new(uri, 'Content-Type' => 'application/json')
      end

      # @return [String]
      def http_method
        bridge.http_method.capitalize
      end

      # @return [Hash(String, JSON)]
      def data
        bridge.data
      end

      # @return [String]
      def outbound_url
        bridge.outbound_url
      end

      # @return [ActiveRecord::Relation(Header)]
      def headers
        @headers ||= bridge.headers
      end

      # Checks if this request is a test event
      #
      # @return [Bool]
      def test_env?
        event.test
      end
    end
  end
end
