# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def contact
    @full_name = params[:full_name]
    @message = params[:message]
    @subject = params[:subject]
    @sender = params[:email]

    mail subject: @subject, reply_to: @sender
  end
end
