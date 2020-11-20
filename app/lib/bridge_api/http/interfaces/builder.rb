# frozen_string_literal: true

module BridgeApi
  module Http
    module Interfaces
      # Abstract "class"
      module Builder
        def generate
          raise NotImplementedError, 'A request builder class must implement #generate'
        end

        # def payload
        #   raise NotImplementedError, 'A request builder class must implement #payload'
        # end
      end
    end
  end
end
