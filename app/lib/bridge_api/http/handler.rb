# frozen_string_literal: true

module BridgeApi
  module Http
    class Handler
      # Inject a different builder or formatter
      # @param [BridgeApi::Http::Interfaces::Builder] http_builder
      attr_writer :http_builder,
                  # @param [BridgeApi::Http::Interfaces::Formatter] formatter
                  :formatter

      # @param [Integer] event_id
      def initialize(event)
        @event = event
        @bridge = @event.bridge
      end

      def execute
        http, @request = http_builder.generate
        response = http.request request
        # formatter.format! event, request, response
        formatter.format_request! event, request
        formatter.format_response! event, response

        raise Sidekiq::LargeStatusCode if response.code.to_i >= 300
      end

      def cleanup(error)
        formatter.format_error! event, request, error
      end

      private

      attr_accessor :event,
                    :bridge,
                    :request

      # @return [BridgeApi::Http::Interfaces::Builder]
      def http_builder
        @http_builder ||= Builder.new bridge, event.test
      end

      # @return [BridgeApi::Http::Interfaces::Formatter]
      def formatter
        @formatter ||= Formatter.new
      end
    end
  end
end
