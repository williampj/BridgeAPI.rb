# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  before do
    create_user
  end

  subject do
    create_bridge
  end

  it 'belongs to bridge' do
    event1 = Event.create(
      completed: false,
      data: '',
      status_code: 300
    )
    event2 = Event.create(
      completed: false,
      data: '',
      status_code: 300
    )

    subject.events << event1
    subject.events << event2
    expect(event1.bridge).to eq subject
    expect(event2.bridge).to eq subject
  end
end
