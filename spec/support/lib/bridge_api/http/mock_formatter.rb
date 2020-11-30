# frozen_string_literal: true

class MockFormatter
  def format!(_event, _req, _res)
    true
  end

  def format_error!(_event, _req, _res)
    true
  end
end

class MockFailFormatter
  def format!(_event, _req, _res)
    raise StandardError
  end

  def format_error!(event, request, error)
    ::BridgeApi::Http::Formatter.new(
      ::BridgeApi::Http::Deconstructor.new(
        event.bridge.headers
      )
    ).format_error! event, request, error
  end
end
