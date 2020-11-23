# frozen_string_literal: true

# `data` column:
# {
#   'inbound' => {
#     'payload' => {
#       'bridge_id' => '1',
#       'top_level_key' => 'present',
#       'nested_key_1' => {
#         'nested_key_2' => 'present'
#       }
#     },
#     'dateTime' => '2020-11-21T13:59:47.349Z',
#     'ip' => '0.0.0.0',
#     'contentLength' => 101
#   },
#   'outbound' => [
#     {
#       'request' => {
#         'payload' => {
#           'first_name' => 'Lee',
#           'last_name' => 'Oswald',
#           'username' => 'GrassyKnoll',
#           'email' => 'kgb63@yandex.ru',
#           'top_level_key' => 'present',
#           'nested_key' => 'present'
#         },
#         'dateTime' => '2020-11-21T13:59:51.076Z',
#         'contentLength' => '141',
#         'uri' => 'https://c41a7126-a18c-4af6-880e-6857771a35c8.mock.pstmn.io/success_event',
#         'headers' => [
#           {
#             'key' => 'content-type',
#             'value' => 'application/json'
#           },
#           {
#             'key' => 'should_be_filtered',
#             'value' => 'FILTERED'
#           },
#           {
#             'key' => 'not_filtered',
#             'value' => 'bridge api'
#           },
#         ]
#       },
#       'response' => {
#         'dateTime' => '2020-11-21T13:59:51.076Z',
#         'statusCode' => '200',
#         'message' => 'OK',
#         'size' => 13,
#         'payload' => {
#           'hello' => 'world'
#         }
#       }
#     }
#   ]
# }
class Event < ApplicationRecord
  before_validation :set_urls
  validates :test, inclusion: [true, false]
  validates :completed, inclusion: [true, false]
  validates :status_code, numericality: { greater_than_or_equal_to: 100, less_than_or_equal_to: 599 }, allow_nil: true
  validate :completed_at_format
  validate :data_json_object

  belongs_to :bridge

  # Marks an event as complete & saves
  def complete!
    self.completed = true
    self.completed_at = Time.now.utc
    save! # TODO: With a bang?
  end

  # Parses `data` and fetches the payload from the
  # inbound request.
  #
  # @return [Hash(String, String)]
  def inbound_payload
    JSON.parse(data)['inbound']['payload']
  end

  private

  # TODO: Pass in bridge (or urls) to prevent db hit
  def set_urls
    self.inbound_url = bridge&.inbound_url
    self.outbound_url = bridge&.outbound_url
  end

  def data_json_object
    data = JSON.parse(self.data)
    %w[inbound outbound].all? { |key| data.include?(key) } &&
      %w[payload dateTime ip contentLength].all? { |key| data['inbound'].include?(key) } ||
      errors.add(
        :data,
        'must include the keys: "inbound", "outbound",
                  while "inbound" must include the keys "payload", "dateTime", "ip", "contentLength"'
      )
  rescue JSON::ParserError, TypeError
    errors.add(:data, 'object must be a valid json object')
  end

  def completed_at_format
    return if completed_at.nil? || completed_at.instance_of?(ActiveSupport::TimeWithZone)

    errors.add(:completed_at, '"completed_at" must be a Time instance if event is completed')
  end
end
