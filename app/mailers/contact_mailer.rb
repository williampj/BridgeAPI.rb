# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def contact(payload)
    @full_name = payload['full_name']
    @message = payload['message']
    @subject = payload['subject']
    @sender = payload['email']

    mail subject: @subject, reply_to: @sender
  end
end
