# frozen_string_literal: true

time = Time.now.utc - 1.day

FactoryBot.define do
  factory :seed_event, class: 'Event' do
    inbound_url { 'myfakeinbound.com' }
    outbound_url { 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event' }

    trait :success do
      completed { true }
      aborted { false }
      completed_at { time + 2.minute }
      status_code { 200 }
      data do
        {
          'inbound' => {
            'payload' => {
              'bridge_id' => '1',
              'top_level_key' => 'present',
              'nested_key_1' => {
                'nested_key_2' => 'present'
              }
            },
            'dateTime' => time,
            'ip' => '::1',
            'contentLength' => 101
          },
          'outbound' => [
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 1.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {
                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' =>
               {
                 'dateTime' => time + 2.minute,
                 'statusCode' => '200',
                 'message' => 'OK',
                 'size' => 13,
                 'payload' => {
                   'hello' => 'world'
                 }
               }
            }
          ]
        }.to_json
      end
    end

    trait :success_with_retries do
      completed { true }
      aborted { false }
      completed_at { time + 4.minute }
      status_code { 200 }
      data do
        {
          'inbound' => {
            'payload' => {
              'bridge_id' => '1',
              'top_level_key' => 'present',
              'nested_key_1' => {
                'nested_key_2' => 'present'
              }
            },
            'dateTime' => time,
            'ip' => '::1',
            'contentLength' => 101
          },
          'outbound' => [
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 1.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {
                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' =>
               {
                 'dateTime' => time + 2.minute,
                 'statusCode' => '404',
                 'message' => 'OK',
                 'size' => 13,
                 'payload' => {
                   'hello' => 'world'
                 }
               }
            },
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 3.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {

                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' => {
                'dateTime' => time + 4.minute,
                'statusCode' => '404',
                'message' => 'OK',
                'size' => 13,
                'payload' => {
                  'hello' => 'world'
                }
              }
            },
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 5.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {
                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' => {
                'dateTime' => time + 6.minute,
                'statusCode' => '200',
                'message' => 'OK',
                'size' => 13,
                'payload' => {
                  'hello' => 'world'
                }
              }
            }
          ]
        }.to_json
      end
    end

    trait :failed do
      completed { true }
      aborted { false }
      completed_at { time + 6.minute }
      status_code { 500 }
      data do
        {
          'inbound' => {
            'payload' => {
              'bridge_id' => '1',
              'top_level_key' => 'present',
              'nested_key_1' => {
                'nested_key_2' => 'present'
              }
            },
            'dateTime' => time,
            'ip' => '::1',
            'contentLength' => 101
          },
          'outbound' => [
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 1.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {
                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' =>
               {
                 'dateTime' => time + 2.minute,
                 'statusCode' => '500',
                 'message' => 'Internal Server Error',
                 'size' => 13,
                 'payload' => {
                   'hello' => 'world'
                 }
               }
            },
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 3.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {

                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' => {
                'dateTime' => time + 4.minute,
                'statusCode' => '500',
                'message' => 'Internal Server Error',
                'size' => 13,
                'payload' => {
                  'hello' => 'world'
                }
              }
            },
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 5.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {
                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' => {
                'dateTime' => time + 6.minute,
                'statusCode' => '500',
                'message' => 'Internal Server Error',
                'size' => 13,
                'payload' => {
                  'hello' => 'world'
                }
              }
            }
          ]
        }.to_json
      end
    end

    trait :ongoing do
      completed { false }
      aborted { false }
      completed_at { time + 2.minute }
      data do
        {
          'inbound' => {
            'payload' => {
              'bridge_id' => '1',
              'top_level_key' => 'present',
              'nested_key_1' => {
                'nested_key_2' => 'present'
              }
            },
            'dateTime' => time,
            'ip' => '::1',
            'contentLength' => 101
          },
          'outbound' => []
        }.to_json
      end
    end

    trait :aborted do
      completed { true }
      aborted { true }
      completed_at { time + 2.minute }
      data do
        {
          'inbound' => {
            'payload' => {
              'bridge_id' => '1',
              'top_level_key' => 'present',
              'nested_key_1' => {
                'nested_key_2' => 'present'
              }
            },
            'dateTime' => time,
            'ip' => '::1',
            'contentLength' => 101
          },
          'outbound' => []
        }.to_json
      end
    end

    trait :aborted_with_retries do
      completed { true }
      aborted { true }
      completed_at { time + 2.minute }
      status_code { 500 }
      data do
        {
          'inbound' => {
            'payload' => {
              'bridge_id' => '1',
              'top_level_key' => 'present',
              'nested_key_1' => {
                'nested_key_2' => 'present'
              }
            },
            'dateTime' => time,
            'ip' => '::1',
            'contentLength' => 101
          },
          'outbound' => [
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 1.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {
                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' =>
               {
                 'dateTime' => time + 2.minute,
                 'statusCode' => '500',
                 'message' => 'Internal Server Error',
                 'size' => 13,
                 'payload' => {
                   'hello' => 'world'
                 }
               }
            },
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 3.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {

                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' => {
                'dateTime' => time + 4.minute,
                'statusCode' => '500',
                'message' => 'Internal Server Error',
                'size' => 13,
                'payload' => {
                  'hello' => 'world'
                }
              }
            },
            {
              'request' => {
                'payload' => {
                  'hello' => 'world'
                },
                'dateTime' => time + 5.minute,
                'contentLength' => '17',
                'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
                'headers' => [
                  {
                    'key' => 'content-type',
                    'value' => 'application/json'
                  },
                  {
                    'key' => 'accept-encoding',
                    'value' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
                  },
                  {
                    'key' => 'accept',
                    'value' => '*/*'
                  },
                  {
                    'key' => 'user-agent',
                    'value' => 'Ruby'
                  },
                  {
                    'key' => 'host',
                    'value' => 'c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io'
                  },
                  {
                    'key' => 'connection',
                    'value' => 'close'
                  },
                  {
                    'key' => 'content-length',
                    'value' => '17'
                  }
                ]
              },
              'response' => {
                'dateTime' => time + 6.minute,
                'statusCode' => '500',
                'message' => 'Internal Server Error',
                'size' => 13,
                'payload' => {
                  'hello' => 'world'
                }
              }
            }
          ]
        }.to_json
      end
    end
  end
end
