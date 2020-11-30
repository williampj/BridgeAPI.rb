# frozen_string_literal: true

module BridgeApi
  module Http
    module Interfaces
      # Abstract "class"
      module Deconstructor
        def deconstruct(_key, _value)
          raise NotImplementedError, 'A request builder class must implement #deconstruct(key, value)'
        end
      end
    end
  end
end
