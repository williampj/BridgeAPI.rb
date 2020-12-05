# frozen_string_literal: true

class ContactUsController < ApplicationController
  def index
    ContactUsMailer.contact_us(
      contact_us_params[:full_name],
      contact_us_params[:email],
      contact_us_params[:message]
    ).deliver_later
    render_message
  end

  protected

  def contact_us_params
    params.permit(:full_name, :email, :message)
  end
end
