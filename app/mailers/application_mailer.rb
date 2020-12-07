# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default to: 'test.bridgeapi@gmail.com', from: 'test.bridgeapi@gmail.com'
  layout 'mailer'
end
