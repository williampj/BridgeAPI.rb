# frozen_string_literal: true

class MockPayloadParser
  def parse(_payload, _user_data)
    { data: 'hello world' }
  end
end
