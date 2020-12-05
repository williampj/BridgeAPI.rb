# frozen_string_literal: true

class ContactUsController < ApplicationController
  def create
<<<<<<< HEAD
    ContactWorker.perform_async(set_payload)
    status 202 # accepted
=======
    ContactUsMailer.contact_us(
      contact_us_params[:full_name],
      contact_us_params[:email],
      contact_us_params[:message]
    ).deliver_later
    render_message
>>>>>>> c39e590428bc850d3d509b9d2f43bba87c843080
  end

  protected

  def contact_us_params
    params.permit(:full_name, :email, :message)
  end

  def set_payload
    {
      'full_name' => contact_us_params[:full_name],
      'email' => contact_us_params[:email],
      'message' => contact_us_params[:message]
    }
  end
end
