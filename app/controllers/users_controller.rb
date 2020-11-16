# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize_request, only: %i[show destroy update]

  def show
    render json: { user: @current_user.safe_json }, status: 200
  end

  def create
    user = User.new(user_params)
    user.save!
    token = JsonWebToken.encode({ user_id: user.id })
    render json: { user: user.safe_json, token: token }, status: 201 # Created
  rescue ActiveRecord::RecordInvalid
    render json: { error: 'email or password is invalid' }, status: 422 # Unprocessable Entity
  end

  def destroy
    @current_user.destroy
  end

  def update
    return if user_params[:password] && !update_password

    if @current_user.update(user_params)
      render json: @current_user.safe_json, status: 200 # OK
    else
      render json: {}, status: 400 # Bad Request
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :notifications)
  end

  def update_password
    if @current_user.authenticate(params[:current_password])
      @current_user.password = user_params[:password]
    else
      render json: { error: 'password is incorrect' }, status: 400 # Bad Request
      nil
    end
  end
end
