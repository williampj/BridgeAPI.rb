# frozen_string_literal: true

class ContactUsMailer < ApplicationMailer
  def contact_us(full_name:, email:, message:)
    @full_name = full_name
    @email = email
    @message = message

    mail(to: 'test.bridgeapi@gmail.com', subject: 'New Message')
  end
end
