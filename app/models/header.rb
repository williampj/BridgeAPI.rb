# frozen_string_literal: true

class Header < ApplicationRecord
  validates :key, presence: true
  validates :value, presence: true

  belongs_to :bridge
end
