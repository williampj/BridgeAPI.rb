# frozen_string_literal: true

class Header < ApplicationRecord
  validates :key, presence: true
  validates :value, presence: true

  belongs_to :bridge

  before_validation :downcase_key

  private

  # Downcase all keys since requests do that anyway.
  # With a non-normalized case, we can't match headers
  # when deconstructing requests to save.
  def downcase_key
    key.downcase!
  end
end
