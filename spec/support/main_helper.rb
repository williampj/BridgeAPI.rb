# frozen_string_literal: true

module MainHelper
  def create_user
    @current_user = User.create(email: 'admin@bridge.io', password: 'password', notifications: false)
    @token = JsonWebToken.encode(user_id: @current_user.id)
  end

  def authenticated_token
    { 'BRIDGE-JWT': @token }
  end

  def create_other_user
    @other_user = User.create(email: 'tester@bridge.io', password: 'password', notifications: false)
  end

  def bridge_hash
    {
      user: @current_user,
      title: 'bridge',
      outbound_url: "doggoapi.io/#{(String(rand).split '.')[1]}",
      method: 'POST',
      retries: 5,
      delay: 15,
      data: { payload: '{}', test_payload: '{}' }
    }
  end

  def create_bridge
    Bridge.new(
      **bridge_hash
    )
  end
end
