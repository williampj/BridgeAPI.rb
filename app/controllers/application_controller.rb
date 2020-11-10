class ApplicationController < ActionController::API
  attr_accessor :current_user

  TOKEN_HEADER = 'BRIDGE-JWT'.freeze
  USER_ERROR_MSG = 'ERROR: Could not find user with decoded JWT. This should not happen.'.freeze

  # Set this method as a before_action for routes you want
  # to protect with JWT authentication. Your route action
  # will not be hit unless the token is valid. You can safely
  # use `@current_user` in any route without checking for `nil`.
  #
  # Fetches the JWT from request headers, decodes &
  # tries to find the user. If the user cannot be found,
  # the token has expired or the token is fake/invalid
  # a 401 error will be thrown.
  def authorize_request
    token = request.headers[TOKEN_HEADER]&.split(' ')&.last
    decoded_token = JsonWebToken.decode(token)
    @current_user = User.find(decoded_token['user_id'])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error ActiveSupport::LogSubscriber.new.send(:color, USER_ERROR_MSG, :red)
    render json: {}, status: 404 # Not Found
  rescue JWT::DecodeError
    render json: {}, status: 401 # Unauthorized
  rescue JWT::ExpiredWebToken
    render json: { error: 'You need to log in again' }, status: 401 # unauthorized
  end
end
