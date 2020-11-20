# frozen_string_literal: true

def test_url
  "doggoapi.io/#{String(rand).split('.')[1]}"
end

user = User.create(email: 'admin@bridge.io', password: 'password', notifications: false)
user2 = User.create(email: 'tester@bridge.io', password: 'password', notifications: false)

bridge = Bridge.create(
  user_id: user.id,
  title: 'My First Bridge',
  inbound_url: 'bridgeapi.com/249634',
  outbound_url: 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
  method: 'POST',
  retries: 5,
  delay: 15,
  data: {
    payload: {
      first_name: 'Lee',
      last_name: 'Oswald',
      username: 'GrassyKnoll',
      email: 'kgb63@yandex.ru',
      top_level_key: '$payload.top_level_key',
      nested_key: '$payload.nested_key_1.nested_key_2'
    }.to_json,
    test_payload: '{"test_key_one":"testerstring","test_key_two":["stringinarray"]}'
  }
)

bridge.environment_variables << EnvironmentVariable.create(key: 'DATABASE_URL', value: 'a102345ij2')
bridge.environment_variables << EnvironmentVariable.create(key: 'database_password', value: 'supersecretpasswordwow')
bridge.headers << Header.create(key: 'SHOULD_BE_FILTERED', value: '$env.DATABASE_URL')
bridge.headers << Header.create(key: 'not_filtered', value: 'bridge api')

bridge2 = Bridge.create(
  user_id: user2.id,
  title: 'My Second Bridge',
  inbound_url: 'bridgeapi.com/746353',
  outbound_url: test_url,
  method: 'PATCH',
  retries: 3,
  delay: 0,
  data: {
    payload: '{"FirstName":"Booths","LastName":"John","UserName":"FordTheatre","Password":{"nested":"sic temper tyrannis"},"Email":"mail@mail.com"}',
    test_payload: '{"test_key_one":{"nested":11},"test_key_two":888}'
  }
)

bridge2.environment_variables << EnvironmentVariable.create(key: 'database', value: 'z9992374623')
bridge2.environment_variables << EnvironmentVariable.create(key: 'database_password', value: '@@@!++#*!@')
bridge2.headers << Header.create(key: 'X_API_KEY', value: 'returntheslab')
bridge2.headers << Header.create(key: 'Authentication', value: 'Bearer *************')

# 5.times do
#   bridge.events << Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: 'bridgeapi.com/249634', data: '', status_code: 300)
#   bridge2.events << Event.create(completed: false, outbound_url: bridge2.outbound_url, inbound_url: 'bridgeapi.com/746353', data: '', status_code: 302)
# end
