# frozen_string_literal: true

module BridgeApi
  module Http
    # Deconstructs the request headers. Replaces
    # any headers that contain environment variables with
    # placeholder values to prevent data leakage.
    class Deconstructor
      include Interfaces::Deconstructor

      # @param [ActiveRecord::Relation(Header)] user_headers
      def initialize(headers)
        @headers = headers
        @header_keys = headers.pluck(:key)
      end

      # Prevents sensitive headers from being stored in cleared text.
      # If the header value can be found & the value contains `$env`
      # we return a safe value otherwise the real value is returned.
      #
      # @param [String] key
      # @param [String] value
      #
      # @return [String]
      def deconstruct(key, value)
        # Don't waste time on querying unless we know the header exists
        return value unless header_keys.include?(key)

        if headers.find_by(key: key).value.include?('$env')
          'FILTERED'
        else
          value
        end
      end

      private

      attr_reader :headers, :header_keys
    end
  end
end
