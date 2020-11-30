# frozen_string_literal: true

class MockSuccessBuilder
  def generate
    http = Net::HTTP.new(URI('myfakeoutbound.com'))
    http.use_ssl = true
    [
      http,
      Net::HTTP::Post.new(URI('https://myfakeoutbound.com'), 'Content-Type' => 'application/json')
    ]
  end
end

class MockFailBuilder
  def generate
    http = Net::HTTP.new(URI('myfakeoutbound2.com'))
    http.use_ssl = true
    [
      http,
      Net::HTTP::Post.new(URI('https://myfakeoutbound2.com'), 'Content-Type' => 'application/json')
    ]
  end
end
