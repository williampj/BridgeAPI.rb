# frozen_string_literal: true

class ContactController < ApplicationController
  before_action :set_payload

  def create
    ContactWorker.perform_async(@payload)
    head :accepted
  end

  private

  def contact_params
    params.permit(:full_name, :email, :message, :subject)
  end

  def set_payload
    @payload = {
      'full_name' => contact_params[:full_name],
      'email' => contact_params[:email],
      'message' => contact_params[:message],
      'subject' => contact_params[:subject]
    }
    render json: { error: 'One or more fields were empty' }, status: :unprocessable_entity if invalid_payload?
  end

  def invalid_payload?
    @payload.any? { |_field, value| value.empty? }
  end
end
