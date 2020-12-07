# frozen_string_literal: true

# require_relative '../spec/factories/seed_event_factory'

def test_url
  "doggoapi.io/#{String(rand).split('.')[1]}"
end

user = User.find_or_create_by(
  email: 'demo@demo.com',
  password_digest: '$2a$12$YI.Nl33QVeq3EWruK4QL5.PpZIFYW7wwGNlclCruIXLP4vVFvxtj6', # password
  notifications: false
)

bridge = Bridge.find_or_create_by(
  user_id: user.id,
  title: 'My First Bridge',
  inbound_url: 'bridgeapi.com/249634',
  outbound_url: 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
  http_method: 'POST',
  retries: 5,
  delay: 15,
  slug: "e6378d63002a55bd7266a526", 
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

EnvironmentVariable.find_or_create_by(key: 'DATABASE_URL', value: 'a102345ij2', bridge_id: bridge.id)
EnvironmentVariable.find_or_create_by(key: 'database_password', value: 'supersecretpasswordwow', bridge_id: bridge.id)
Header.find_or_create_by(key: 'SHOULD_BE_FILTERED', value: '$env.DATABASE_URL', bridge_id: bridge.id)
Header.find_or_create_by(key: 'not_filtered', value: 'bridge api', bridge_id: bridge.id)

bridge2 = Bridge.find_or_create_by(
  user_id: user.id,
  title: 'My Second Bridge',
  inbound_url: 'bridgeapi.com/746353',
  outbound_url: test_url,
  http_method: 'PATCH',
  retries: 3,
  delay: 0,
  slug: "e0d2b8a7af45db0296316ee8", 
  data: {
    payload: '{"FirstName":"Booths","LastName":"John","UserName":"FordTheatre","Password":{"nested":"sic temper tyrannis"},"Email":"mail@mail.com"}',
    test_payload: '{"test_key_one":{"nested":11},"test_key_two":888}'
  }
)

EnvironmentVariable.find_or_create_by(key: 'database', value: 'z9992374623', bridge_id: bridge2.id)
EnvironmentVariable.find_or_create_by(key: 'database_password', value: '@@@!++#*!@', bridge_id: bridge2.id)
Header.find_or_create_by(key: 'X_API_KEY', value: 'returntheslab', bridge_id: bridge2.id)
Header.find_or_create_by(key: 'Authentication', value: 'Bearer *************', bridge_id: bridge2.id)

%i[success success_with_retries failed aborted aborted_with_retries ongoing].each do |trait|
  FactoryBot.create(:seed_event, trait, bridge_id: bridge.id)
end

5.times do
  FactoryBot.create(:seed_event, :ongoing, bridge_id: bridge.id)
end
