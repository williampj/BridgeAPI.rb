class UserMailer < ApplicationMailer
  default from: 'notifications@email.com'

  def welcome_email
    @user = params[:user]
    @url = 'http://example.com/login'
    mail(to: @user.email, subject: 'welcome')
  end
end
