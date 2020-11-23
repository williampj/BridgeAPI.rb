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
  http_method: 'POST',
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
  http_method: 'PATCH',
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

5.times do
  bridge.events.create(completed: false, outbound_url: 'ip.jsontest.com', inbound_url: 'ip.jsontest.com', data: '{"inbound":{"payload":{"FirstName":"Lee","LastName":"Oswald","UserName":"GrassyKnoll","Password":{"nested":"magic bullet"},"Email":"kgb63@yandex.ru"},"dateTime":"2020-11-20T02:02:55.745Z","ip":"::1","contentLength":152},"outbound":[{"request":{"payload":{"FirstName":"Lee","LastName":"Oswald","UserName":"GrassyKnoll","Password":{"nested":"magic bullet"},"Email":"kgb63@yandex.ru"},"dateTime":"2020-11-20T02:02:55.832Z","contentLength":7},"response":{"dateTime":"2020-11-20T02:02:55.882Z","statusCode":"200","message":"OK","size":7,"payload":{"ip":"153.33.111.24"}}}]}', status_code: 300)
  bridge2.events.create(completed: false, outbound_url: 'ip.jsontest.com', inbound_url: 'ip.jsontest.com', data: '{"inbound":{"payload":{"FirstName":"Billy","LastName":"Bob","UserName":"Hitman","Password":{"nested":"badaboom"},"Email":"agag@av.ru"},"dateTime":"2020-10-25T02:10:55.745Z","ip":"::2","contentLength":152},"outbound":[{"request":{"payload":{"FirstName":"Lee","LastName":"Oswald","UserName":"GrassyKnoll","Password":{"nested":"magic bullet"},"Email":"kgb63@yandex.ru"},"dateTime":"2020-11-20T02:02:55.832Z","contentLength":7},"response":{"dateTime":"2020-11-20T02:02:55.882Z","statusCode":"200","message":"OK","size":7,"payload":{"ip":"153.33.111.24"}}}]}', status_code: 302)
end
