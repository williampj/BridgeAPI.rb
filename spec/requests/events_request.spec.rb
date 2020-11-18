# frozen_string_literal: true

RSpec.describe 'Events', type: :request do
  before(:context) do
    create_event
  end

  after(:context) do
    destroy_event
  end
end
