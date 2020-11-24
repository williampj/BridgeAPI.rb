# frozen_string_literal: true

module BridgeApi
  module SyntaxParser
    module Interfaces
      # Abstract "class"
      module PayloadParser
        def parse
          raise NotImplementedError, 'A payload parser class must implement #parse(incoming_request, user_data)'
        end
      end
    end
  end
end
