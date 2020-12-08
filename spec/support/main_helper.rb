# frozen_string_literal: true

def random_email
  local = []
  8.times { |_| local.push(('a'..'z').to_a.sample) }
  domain = ['aol.com', 'nsa.gov', 'jubii.dk', 'kreml.ru', 'hotmail.com', 'netscape.com'][rand(6)]
  "#{local.join}@#{domain}"
end

module MainHelper
  def create_user
    @user = User.create(email: random_email, password: 'password', notifications: false)
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  def authenticated_token
    { 'BRIDGE-JWT': @token }
  end

  def create_other_user
    @other_user = User.create(email: 'tester@bridge.io', password: 'password', notifications: false)
  end

  def bridge_hash
    {
      user: @user,
      title: 'bridge',
      outbound_url: "doggoapi.io/#{(String(rand).split '.')[1]}",
      http_method: 'POST',
      retries: 5,
      slug: 'b53b9c093a75df827ca08a7f5a52bc86',
      delay: 15,
      data: { payload: '{}', test_payload: '{}' }
    }
  end

  def create_bridge
    Bridge.new(
      **bridge_hash
    )
  end

  # rubocop:disable Metrics/MethodLength
  def event_data
    {
      'inbound' => {
        'payload' => {
          'FirstName' => 'Lee',
          'LastName' => 'Oswald',
          'UserName' => 'GrassyKnoll',
          'Password' => { 'nested' => 'magic bullet' },
          'Email' => 'kgb63@yandex.ru'
        },
        'dateTime' => '2020-11-17',
        'ip' => '::1',
        'contentLength' => '152',
        'headers' => []
      },
      'outbound' => [
        { 'request' => {
          'payload' => {
            'FirstName' => 'Lee',
            'LastName' => 'Oswald',
            'UserName' => 'GrassyKnoll',
            'Password' => { 'nested' => 'magic bullet' },
            'Email' => 'kgb63@yandex.ru'
          },
          'dateTime' => '2020-11-17',
          'contentLength' => '7'
        },
          'response' => {
            'date' => '2020-11-17',
            'time' => '03:23:35',
            'status_code' => '200',
            'message' => 'OK',
            'size' => '7',
            'payload' => { 'ip' => '153.33.111.24' }
          } }
      ]
    }.to_json
  end
  # rubocop:enable Metrics/MethodLength

  def create_event
    @bridge = create_bridge
    @bridge.save
    @event = Event.create({
                            bridge_id: @bridge.id,
                            data: event_data,
                            status_code: 200,
                            completed: true,
                            completed_at: Time.now.utc + 30
                          })
  end

  def destroy_event
    @event.destroy!
  end

  def contact_payload
    {
      full_name: 'Alexis de Tocqueville',
      email: 'comte@senat.fr',
      subject: 'Democracy in America',
      message: 'Bonjour dear WAA team. The future belongs to you!'
    }
  end

  def worker_contact_payload
    {
      'full_name' => 'Alexis de Tocqueville',
      'email' => 'comte@senat.fr',
      'subject' => 'Democracy in America',
      'message' => 'Bonjour dear WAA team. The future belongs to you!'
    }
  end
end
