# frozen_string_literal: true

class MockDeconstructor
  def deconstruct(_key, value)
    value
  end
end
