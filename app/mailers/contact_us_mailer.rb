# frozen_string_literal: true

class ContactUsMailer < ApplicationMailer
  default from: 'angelbates5@yahoo.com'

  def contact_us
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: 'angelbates5@yahoo.com', subject: 'Welcome to My Awesome Site')
  end
end
