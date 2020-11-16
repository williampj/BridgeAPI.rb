def test_url
  'doggoapi.io/' + String(rand).split('.')[1]
end

user = User.create(email: 'admin@bridge.io', password: 'password', notifications: false)
user2 = User.create(email: 'tester@bridge.io', password: 'password', notifications: false)

bridge = Bridge.create(
  user_id: user.id,
  name: 'My First Bridge', 
  inbound_url: 'bridgeapi.com/249634', 
  outbound_url: 'ip.jsontest.com',
  method: 'POST', 
  retries: 5, 
  delay: 15,
  data: { payload: "{\"FirstName\":\"Lee\",\"LastName\":\"Oswald\",\"UserName\":\"GrassyKnoll\",\"Password\":{\"nested\":\"magic bullet\"},\"Email\":\"kgb63@yandex.ru\"}", test_payload: {} }
)

bridge.environment_variables << EnvironmentVariable.create(key: 'database', value: 'a102345ij2')
bridge.environment_variables << EnvironmentVariable.create(key: 'database_password', value: 'supersecretpasswordwow')
bridge.headers << Header.create(key: 'X_API_KEY', value: 'ooosecrets')
bridge.headers << Header.create(key: 'Authentication', value: 'Bearer &&&&&&&&&&&&&&&&')

bridge2 = Bridge.create(
  user_id: user2.id,
  name: 'My Second Bridge', 
  payload: "{\"FirstName\":\"Booths\",\"LastName\":\"John\",\"UserName\":\"FordTheatre\",\"Password\":{\"nested\":\"sic temper tyrannis\"},\"Email\":\"mail@mail.com\"}", 
  inbound_url: Bridge.generate_inbound_url, 
  outbound_url: test_url, 
  method: 'PATCH', 
  retries: 0, 
  delay: 0,
  data: { payload: "{\"FirstName\":\"Booths\",\"LastName\":\"John\",\"UserName\":\"FordTheatre\",\"Password\":{\"nested\":\"sic temper tyrannis\"},\"Email\":\"mail@mail.com\"}", test_payload: {} }
)

bridge2.environment_variables << EnvironmentVariable.create(key: 'database', value: 'z9992374623')
bridge2.environment_variables << EnvironmentVariable.create(key: 'database_password', value: '@@@!++#*!@')
bridge2.headers << Header.create(key: 'X_API_KEY', value: 'returntheslab')
bridge2.headers << Header.create(key: 'Authentication', value: 'Bearer *************')

5.times do
  bridge.events << Event.create(completed: false, outbound_url: bridge.outbound_url, inbound_url: test_url, data: '', status_code: 300)
  bridge2.events << Event.create(completed: false, outbound_url: bridge2.outbound_url, inbound_url: test_url, data: '', status_code: 302)
end
