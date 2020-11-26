# frozen_string_literal: true

module BridgeApi
  module Http
    # Handles formatting requests & responses. Accepts a deconstructor
    # to remove sensitive headers.
    #
    # Example:
    #
    # ```ruby
    # event = Event.find 1
    # deconstructor = BridgeApi::Http::Deconstructor.new event.bridge.headers
    # formatter = BridgeApi::Http::Formatter.new deconstructor
    # uri = URI('http://example.com/some_path?query=string')
    #
    # Net::HTTP.start(uri.host, uri.port) do |http|
    #   request = Net::HTTP::Get.new uri
    #   response = http.request request # Net::HTTPResponse object
    #   formatter.format! event, request, response
    # resuce StandardError => e
    #   formatter.format_error! event, request, e
    # end
    # ```
    class Formatter
      include Interfaces::Formatter

      # @param [BridgeApi::Http::Interfaces::Deconstructor] deconstructor
      def initialize(deconstructor)
        @deconstructor = deconstructor
      end

      # Mutates the event object by storing a formatted request
      # & response inside `event.data`
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
        event.status_code = res.code
      end

      # Mutates the event object by storing a formatted request
      # & error inside `event.data`.
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
        event
      end

      private

      attr_reader :deconstructor

      # Formats the response without saving the entire object.
      #
      # @param [Net::HTTPResponse] res
      #
      # @return [Hash(String, To many unions)]
      def formatted_response(response)
        {
          dateTime: DateTime.now.utc,
          statusCode: response.code,
          message: response.message,
          size: response.size,
          payload: response.code.to_i >= 300 ? {} : JSON.parse(response.body)
        }
      end

      # Formats the request without saving the entire object.
      #
      # @param [Net::HTTPResponse] req
      #
      # @return [Hash(Symbol, To many unions)]
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
      #
      # @return [Hash(Symbol, String)]
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
