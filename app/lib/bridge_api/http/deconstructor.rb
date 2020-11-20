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
        # Remove any headers that don't contain `$env` as they
        # don't need to be filtered. Keys are downcased because
        # `request.each_header` returns headers that are downcased.
        @header_keys = headers.where('value like ?', '$env%').pluck(:key).map(&:downcase)
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
        header_keys.include?(key) ? 'FILTERED' : value
      end

      private

      attr_reader :headers, :header_keys
    end
  end
end
