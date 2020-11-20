# frozen_string_literal: true

module BridgeApi
  module Http
    # Handles formatting requests & responses
    class Formatter
      include Interfaces::Formatter

      def initialize; end

      # Mutate the event object by storing a formatted request inside
      # data.
      #
      # @param [Event] event
      # @param [Net::HTTP] req
      # @param [Net::HTTP::Response] res
      def format!(event, req, res)
        data = JSON.parse(event.data)

        data['outbound'].push({
                                'request' => formatted_request(req),
                                'response' => formatted_response(res)
                              })
        event.data = data.to_json
      end

      # Mutate the event object by storing a formatted request inside
      # data.
      #
      # @param [Event] event
      # @param [Net::HTTP] req
      # @param [Net::HTTP::Response] res
      def format_error!(event, req, error)
        data = JSON.parse(event.data)

        data['outbound'].push({
                                'request' => formatted_request(req),
                                'response' => formatted_error(error)
                              })
        event.data = data.to_json
      end

      # Mutate the event object by storing a formatted request inside
      # data.
      #
      # @param [Event] event
      # @param [Net::HTTP] req
      # def format_request!(event, req)
      #   data = JSON.parse(event.data)

      #   data['outbound'].push({ 'request' => formatted_request(req), 'response' => {} })
      #   event.data = data.to_json
      # end

      # Mutate the event object by storing a formatted request inside
      # data.
      #
      # @param [Event] event
      # @param [Net::HTTP::Response] res
      # def format_response!(event, res)
      #   data = JSON.parse(event.data)

      #   data['outbound'].last['response'] = formatted_response res
      #   event.data = data.to_json
      # end

      # Mutate the event object by storing a formatted error message inside
      # data.
      #
      # @param [Event] event
      # @param [Net::HTTP::TODO] error
      # def format_error!(event, error)
      #   event_data = JSON.parse(event.data)

      #   event_data['outbound'].last['response'] = formatted_error error
      #   event.data = event_data.to_json
      #   # event.save
      # end

      private

      def formatted_response(response)
        {
          dateTime: DateTime.now.utc,
          statusCode: response.code,
          message: response.message,
          size: response.size,
          payload: response.code.to_i >= 300 ? {} : JSON.parse(response.body)
        }
      end

      def formatted_request(request)
        {
          payload: request.body,
          dateTime: DateTime.now.utc,
          contentLength: request.length,
          uri: request.uri.to_s
        }
      end

      def formatted_error(error)
        { message: error.message }
      end
    end
  end
end
