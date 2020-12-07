# frozen_string_literal: true

class ContactUsController < ApplicationController
  def create
    ContactWorker.perform_async(set_payload)
<<<<<<< HEAD
    # ContactWorker.perform(set_payload)
    # render :accepted # status 202 # accepted
    # render json: {}, status: 202
    # response 202
    # render status: 202 # accepted
    head :accepted
=======
    render_message
>>>>>>> 9632ef7bcd38c6f15e85ef20ec96a0bf25b61f63
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
