# frozen_string_literal: true

class ContactUsMailer < ApplicationMailer
  def contact_us(full_name:, email:, message:, subject:)
    @full_name = full_name
    @email = email
    @message = message
    @subject = subject

    mail(subject: "BRIDGEAPI - #{@subject}", from: @email)
  end
end
