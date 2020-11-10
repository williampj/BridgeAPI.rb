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

class Bridge < ApplicationRecord
  validates :name, presence: true
  validates :inbound_url, presence: true, uniqueness: true
  validates :outbound_url, presence: true
  validates :method, inclusion: METHODS
  validates :delay, inclusion: DELAYS
  validates :retries, inclusion: RETRIES

  has_many :environment_variables, dependent: :destroy
  has_many :headers, dependent: :destroy
  has_many :events, dependent: :destroy
  belongs_to :user

  alias_attribute :env_vars, :environment_variables

  def self.generate_inbound_url
    SecureRandom.hex(10)
  end
end
