# frozen_string_literal: true

BOOLEAN = [true, false].freeze

class Event < ApplicationRecord
  before_validation :set_urls
  validates :test, inclusion: { in: BOOLEAN, message: '"test" field must be true or false' }
  validates :completed, inclusion: [true, false]
  validates :status_code, numericality: { greater_than_or_equal_to: 100, less_than_or_equal_to: 599 }, allow_nil: true
  validate :completed_at_format
  validate :data_json_object

  belongs_to :bridge

  def sidebar_format
    updated_at = String(self.updated_at)
    time = date_format(updated_at.split(' ')[1])
    date = updated_at.split(' ')[0]
    { id: id,
      time: time.slice(0..-3),
      date: date,
      status_code: status_code }
  end

  private

  def date_format(time)
    year = time.split('-')[0]
    month = time.split('-')[1]
    day = time.split('-')[2]
    "#{year}-#{month}-#{day}"
  end

  def set_urls
    self.inbound_url = bridge.inbound_url
    self.outbound_url = bridge.outbound_url
  end

  def data_json_object
    data = JSON.parse(self.data)
    %w[inbound outbound].all? { |key| data.include?(key) } &&
      %w[payload date time ip content_length].all? { |key| data['inbound'].include?(key) } ||
      errors.add(
        :data,
        'must include the keys: "inbound", "outbound",
                  while "inbound" must include the keys "payload", "date", "time", "ip", "content_length"'
      )
  rescue JSON::ParserError, TypeError
    errors.add(:data, 'object must be a valid json object')
  end

  def completed_at_format
    return if completed_at.nil? || completed_at.instance_of?(ActiveSupport::TimeWithZone)

    errors.add(:completed_at, '"completed_at" must be a Time instance if event is completed')
  end
end
