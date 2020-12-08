require_relative './spec_helper'

RSpec.describe ContactWorker, type: :worker do
  let(:payload) do
    {
      'full_name' => 'Alexis de Tocqueville',
      'email' => 'comte@senat.fr',
      'subject' => 'Democracy in America',
      'message' => 'Bonjour dear WAA team. The future belongs to you!'
    }
  end
  let(:invalid_payload_format) do
    {
      full_name: 'Alexis de Tocqueville',
      email: 'comte@senat.fr',
      subject: 'Democracy in America',
      message: 'Bonjour dear WAA team. The future belongs to you!'
    }
  end

  it 'pushes the job to the queue' do
    expect do
      ContactWorker.perform_async(payload)
    end.to change(ContactWorker.jobs, :size).by(1)
  end

  it 'does not process the job if payload contains symbols' do
    # binding.pry
    ContactWorker.perform_async('invalid payload')
    expect(ContactWorker.jobs.count).to eq(0)
    # expect do
    #   ContactWorker.perform_async(invalid_payload_format)
    # end.to change(ContactWorker.jobs, :size).by(1)
  end
end
