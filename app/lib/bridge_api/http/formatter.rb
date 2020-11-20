# frozen_string_literal: true

module BridgeApi
  module Http
    # Handles formatting requests & responses. Accepts a deconstructor
    # to aid in formatting.
    class Formatter
      include Interfaces::Formatter

      # @param [BridgeApi::Http::Interfaces::Deconstructor] deconstructor
      def initialize(deconstructor)
        @deconstructor = deconstructor
      end

      # Mutates the event object by storing a formatted request inside
      # data.
      #
      # @param [Event] event
      # @param [Net::HTTP] req
      # @param [Net::HTTPResponse] res
      def format!(event, req, res)
        data = JSON.parse(event.data)

        data['outbound'].push({
                                'request' => formatted_request(req),
                                'response' => formatted_response(res)
                              })
        event.data = data.to_json
      end

      # Mutates the event object by storing a formatted request inside
      # data.
      #
      # @param [Event] event
      # @param [Net::HTTP] req
      # @param [StandardError] error
      def format_error!(event, req, error)
        data = JSON.parse(event.data)

        data['outbound'].push({
                                'request' => formatted_request(req),
                                'response' => formatted_error(error)
                              })
        event.data = data.to_json
      end

      private

      attr_reader :deconstructor

      # @param [Net::HTTPResponse] res
      def formatted_response(response)
        {
          dateTime: DateTime.now.utc,
          statusCode: response.code,
          message: response.message,
          size: response.size,
          payload: response.code.to_i >= 300 ? {} : JSON.parse(response.body)
        }
      end

      # @param [Net::HTTP] req
      def formatted_request(request)
        {
          payload: JSON.parse(request.body),
          dateTime: DateTime.now.utc,
          contentLength: request['content-length'],
          uri: request.uri.to_s,
          headers: safe_headers(request)
        }
      end

      # @param [StandardError] error
      def formatted_error(error)
        { message: error.message }
      end

      # Handles creating an Array of all request headers
      #
      # @param [Net::HTTP] req
      #
      # @return [Array(Hash(String, String))]
      def safe_headers(req)
        headers = []
        req.each_header do |key, value|
          headers << {
            key: key,
            value: deconstructor.deconstruct(key, value)
          }
        end

        headers
      end
    end
  end
end
