def test_url
  'doggoapi.io/' + String(rand).split('.')[1]
end

user = User.create(email: 'admin@bridge.io', password: 'password', notifications: false)
user2 = User.create(email: 'tester@bridge.io', password: 'password', notifications: false)

bridge = Bridge.create(
  user: user,
  title: 'My First Bridge',
  outbound_url: 'ip.jsontest.com',
  method: 'POST',
  retries: 5,
  delay: 15,
  data: { payload: '{}', test_payload: '{}' }
)

bridge.environment_variables << EnvironmentVariable.create(key: 'database', value: 'a102345ij2')
bridge.environment_variables << EnvironmentVariable.create(key: 'database_password', value: 'supersecretpasswordwow')
bridge.headers << Header.create(key: 'X_API_KEY', value: 'ooosecrets')
bridge.headers << Header.create(key: 'Authentication', value: 'Bearer &&&&&&&&&&&&&&&&')

bridge2 = Bridge.create(
  user: user2,
  title: 'My Second Bridge',
  outbound_url: test_url,
  method: 'PATCH',
  retries: 0,
  delay: 0,
  data: { payload: '{}', test_payload: '{}' }
)

bridge2.environment_variables << EnvironmentVariable.create(key: 'database', value: 'z9992374623')
bridge2.environment_variables << EnvironmentVariable.create(key: 'database_password', value: '@@@!++#*!@')
bridge2.headers << Header.create(key: 'X_API_KEY', value: 'returntheslab')
bridge2.headers << Header.create(key: 'Authentication', value: 'Bearer *************')

5.times do
  bridge.events.create(completed: false, outbound_url: 'ip.jsontest.com', inbound_url: 'ip.jsontest.com', data: '{"inbound":{"payload":{"FirstName":"Lee","LastName":"Oswald","UserName":"GrassyKnoll","Password":{"nested":"magic bullet"},"Email":"kgb63@yandex.ru"},"dateTime":"2020-11-20T02:02:55.745Z","ip":"::1","contentLength":152},"outbound":[{"request":{"payload":{"FirstName":"Lee","LastName":"Oswald","UserName":"GrassyKnoll","Password":{"nested":"magic bullet"},"Email":"kgb63@yandex.ru"},"dateTime":"2020-11-20T02:02:55.832Z","contentLength":7},"response":{"dateTime":"2020-11-20T02:02:55.882Z","statusCode":"200","message":"OK","size":7,"payload":{"ip":"153.33.111.24"}}}]}', status_code: 300)
  bridge2.events.create(completed: false, outbound_url: 'ip.jsontest.com', inbound_url: 'ip.jsontest.com', data: '{"inbound":{"payload":{"FirstName":"Billy","LastName":"Bob","UserName":"Hitman","Password":{"nested":"badaboom"},"Email":"agag@av.ru"},"dateTime":"2020-10-25T02:10:55.745Z","ip":"::2","contentLength":152},"outbound":[{"request":{"payload":{"FirstName":"Lee","LastName":"Oswald","UserName":"GrassyKnoll","Password":{"nested":"magic bullet"},"Email":"kgb63@yandex.ru"},"dateTime":"2020-11-20T02:02:55.832Z","contentLength":7},"response":{"dateTime":"2020-11-20T02:02:55.882Z","statusCode":"200","message":"OK","size":7,"payload":{"ip":"153.33.111.24"}}}]}', status_code: 302)
end