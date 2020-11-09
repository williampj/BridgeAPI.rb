class Bridge < ApplicationRecord
  validates :name, presence: true
  validates :inbound_url, presence: true
  validates :outbound_url, presence: true
  validates :method, length: { minimum: 3 }
  validates :delay, :numericality => { greater_than_or_equal_to: 0 }
  validates :retries, :numericality => { greater_than_or_equal_to: 0 }


  has_many :environment_variables, dependent: :destroy
  has_many :headers, dependent: :destroy
  has_many :events, dependent: :destroy

  alias_attribute :env_vars, :environment_variables
end
