# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'bridge@bridgeapi.net'
  layout 'mailer'
end
