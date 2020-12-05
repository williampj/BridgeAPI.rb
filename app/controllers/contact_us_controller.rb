# frozen_string_literal: true

class ContactUsController < ApplicationController
  def create
    ContactWorker.perform_async(set_payload)
    status 202 # accepted
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
