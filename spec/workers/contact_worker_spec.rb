# frozen_string_literal: true

require_relative './spec_helper'

RSpec.describe ContactWorker, type: :worker do
  let(:payload) { contact_payload }

  it 'pushes the job to the queue' do
    expect do
      ContactWorker.perform_async(payload)
    end.to change(ContactWorker.jobs, :size).by(1)
  end
end
