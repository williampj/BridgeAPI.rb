# frozen_string_literal: true

module BridgeApi
  module Http
    # TODO: Parser

    # Handles building a HTTP Request object
    class Builder
      SCHEME = 'http://'

      include Interfaces::Builder

      # @param [Bridge] bridge - The bridge that event belongs to
      def initialize(bridge, test_env)
        @bridge = bridge
        @test_env = test_env
      end

      # Generate & return `Net::HTTP`(http) & `Net::HTTP::{http_method}`(request) objects
      #
      # @return [Tuple(Net::HTTP, Net::HTTP::{http_method})]
      def generate
        [net_http, http_request]
      end

      # TODO
      #
      # @return [Hash(String, String)]
      # def payload
      #   parsed_payload
      # end

      private

      attr_reader :request,
                  :bridge

      def net_http
        http = Net::HTTP.new(uri.host, uri.port)
        # http.use_ssl = true # TODO: (uri.scheme == 'https')
        puts 'use ssl'
        http
      end

      def http_request
        @request = net_http_request(uri)
        generate_headers
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
      def generate_headers
        headers.each { |header| request[header['key']] = header['value'] }
      end

      # Parse our custom syntax into the expected values
      #
      # @return [Hash(String, String)]
      def parsed_payload
        # TODO: Parser
        @parsed_payload ||= unparsed_payload # payload_parser.parse unparsed_payload
      end

      # Returns either payload or test_payload depending
      # on the event environment
      #
      # @return [JSON]
      def unparsed_payload
        @unparsed_payload ||= JSON.parse data[test_env? ? 'test_payload' : 'payload']
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
      def net_http_request(uri)
        "Net::HTTP::#{method}".constantize.new(uri, 'Content-Type' => 'application/json')
      end

      # @return [String]
      def method
        bridge.method.capitalize
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
        bridge.headers
      end

      # Checks if this request is a test event
      #
      # @return [Bool]
      def test_env?
        @test_env
      end
    end
  end
end
