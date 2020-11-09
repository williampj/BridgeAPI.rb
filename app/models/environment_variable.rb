class EnvironmentVariable < ApplicationRecord
  validates :key, presence: true
  validates :value, presence: true
  
  belongs_to :bridge
end
