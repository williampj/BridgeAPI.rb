# frozen_string_literal: true

module BridgeApi
  module SyntaxParser
    module Interfaces
      # Abstract "class"
      module HeadersParser
        def parse
          raise NotImplementedError, 'A header parser class must implement #parse(headers)'
        end
      end
    end
  end
end
