# frozen_string_literal: true

class ContactUsController < ApplicationController
  def create
    ContactWorker.perform_async(set_payload)
    # ContactWorker.perform(set_payload)
    # render :accepted # status 202 # accepted
    # render json: {}, status: 202
    # response 202
    # render status: 202 # accepted
    head :accepted
  end

  protected

  def contact_us_params
    params.permit(:full_name, :email, :message, :subject)
  end

  def set_payload
    {
      'full_name' => contact_us_params[:full_name],
      'email' => contact_us_params[:email],
      'message' => contact_us_params[:message],
      'subject' => contact_us_params[:subject]
    }
  end
end
