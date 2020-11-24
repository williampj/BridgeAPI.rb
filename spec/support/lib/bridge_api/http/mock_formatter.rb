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

  def cleanup(_event, _request, _error)
    true
  end
end
