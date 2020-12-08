# frozen_string_literal: true

class ContactController < ApplicationController
  def create
    ContactWorker.perform_async(set_payload)
    head :accepted
  end

  protected

  def contact_params
    params.permit(:full_name, :email, :message, :subject)
  end

  def set_payload
    {
      'full_name' => contact_params[:full_name],
      'email' => contact_params[:email],
      'message' => contact_params[:message],
      'subject' => contact_params[:subject]
    }
  end

  # TODO: Backend validations? (contact model?)
end
