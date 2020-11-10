class UsersController < ApplicationController
  before_action :authorize_request, only: [:show, :destroy, :update]

  def show
    render json: @current_user.safe_json, status: 200 
  end

  def create
    user = User.new(user_params)
    user.save!
    token = JsonWebToken.encode( {user_id: user.id} )
    render json: {user: user.safe_json, token: token}, status: 201 # Created
  
  rescue ActiveRecord::RecordInvalid 
    render json: {error: 'email or password is invalid'}, status: 422 # Unprocessable Entity
  rescue JWT::EncodeError 
    render json: {}, status: 422 # Unprocessable Entity 
  end

  def destroy
    @current_user.destroy 
  end
  
  def update
    if @current_user.update(user_params)
      render json: @current_user.safe_json, status: 204 # No Content
    else
      render json: {}, status: 400 # Bad Request
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :notifications)
  end
end 
