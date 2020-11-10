# frozen_string_literal: true

class Event < ApplicationRecord
  validates :outbound_url, presence: true

  belongs_to :bridge
end
