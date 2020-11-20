# frozen_string_literal: true

BOOLEAN = [true, false].freeze

class Event < ApplicationRecord
  before_validation :set_urls
  validates :test, inclusion: [true, false]
  validates :completed, inclusion: [true, false]
  validates :status_code, numericality: { greater_than_or_equal_to: 100, less_than_or_equal_to: 599 }, allow_nil: true
  validate :completed_at_format
  validate :data_json_object

  belongs_to :bridge

  def complete!
    self.completed = true
    self.completed_at = Time.now.utc
    save! # TODO: With a bang?
  end

  private

  # TODO: Pass in bridge (or urls) to prevent db hit
  def set_urls
    self.inbound_url = bridge.inbound_url
    self.outbound_url = bridge.outbound_url
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
