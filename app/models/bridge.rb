# frozen_string_literal: true

require 'securerandom'

METHODS ||= %w[
  DELETE
  GET
  PATCH
  POST
  PUT
].freeze

DELAYS ||= [
  0,
  15,
  30,
  60,
  1440
].freeze

RETRIES ||= [
  0,
  1,
  3,
  5
].freeze

# `data` column:
# {
#   "payload"      => {}
#   "test_payload" => {}
# }
class Bridge < ApplicationRecord
  before_validation :set_inbound_url, on: :create
  before_validation :set_payloads, on: :create
  before_validation :set_slug, on: :create
  validates :title, presence: true
  validates :inbound_url, presence: true, uniqueness: true
  validates :outbound_url, presence: true
  validates :http_method, inclusion: METHODS
  validates :delay, inclusion: DELAYS
  validates :retries, inclusion: RETRIES
  validate :validate_payloads

  belongs_to :user
  has_many :environment_variables, dependent: :destroy
  has_many :headers, dependent: :destroy
  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :headers, :environment_variables

  def add_event_info
    id, completed_at = latest_event_data

    attributes.merge({
                       'eventCount' => events.count,
                       'completedAt' => completed_at || '',
                       'eventId' => id
                     })
  end

  private

  def set_payloads
    self.data = { payload: '{}', test_payload: '{}' } if data.nil?
  end

  def set_slug
    self.slug = SecureRandom.hex(12)
  end

  def validate_payloads
    return if JSON.parse(data['payload']).instance_of?(Hash) &&
              JSON.parse(data['test_payload']).instance_of?(Hash) &&
              data.keys.count == 2

    errors.add(:data, 'must only contain payload and test_payload keys')
  rescue TypeError
    errors.add(:data, 'keys must be json parsable')
  end

  def set_inbound_url
    self.inbound_url = SecureRandom.hex(10)
  end

  def latest_event_data
    events.where(completed: true)
          .order(completed_at: :desc)
          .limit(1)
          .pluck(:id, :completed_at)
          .first
  end
end
