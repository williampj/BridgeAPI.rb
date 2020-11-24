# frozen_string_literal: true

class MockHeadersParser
  def parse(_headers, &block)
    [
      {
        key: 'header_1',
        value: 'value_1'
      },
      {
        key: 'header_2',
        value: 'value_2'
      }
    ].each { |header| block.call header[:key], header[:value] }
  end
end
