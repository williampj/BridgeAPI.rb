# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def contact_us(payload)
    @full_name = payload['full_name']
    @email = payload['email']
    @message = payload['message']
    @subject = payload['subject']

    mail(subject: "BRIDGEAPI - #{@subject}", to: 'test.bridgeapi@gmail.com', from: @email)
  end
end
