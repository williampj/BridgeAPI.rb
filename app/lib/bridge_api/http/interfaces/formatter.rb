# frozen_string_literal: true

module BridgeApi
  module Http
    module Interfaces
      # Abstract "class"
      module Formatter
        def format!(_event, _req, _res)
          raise NotImplementedError, 'A request builder class must implement #format!(event, req, res)'
        end

        def format_error!(_event, _req, _error)
          raise NotImplementedError, 'A request builder class must implement #format_error!(event, req, error)'
        end
      end
    end
  end
end
