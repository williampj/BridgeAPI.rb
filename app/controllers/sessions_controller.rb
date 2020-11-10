class SessionsController < ApplicationController
  before_action :set_user

  def create
    if @user&.authenticate(user_params[:password])
      token = JsonWebToken.encode( {user_id: @user.id} )
      render json: {token: token}, status: 201 # Created
    else
      render json: {error: "email or password was incorrect"}, status: 403 # Forbidden
    end
  rescue JWT::EncodeError 
    render json: {}, status: 422 # Unprocessable Entity 
  end

  private

  def set_user
    @user = User.find_by_email(user_params[:email])
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
