require_relative './spec_helper'

RSpec.describe EventWorker, type: :worker do
  let(:time) { (Time.zone.today + 6.hours).to_datetime }
  let(:scheduled_job) { described_class.perform_at(time, 'Awesome', true) }

  # it 'Event jobs are enqueued in the scheduled queue' do
  #   described_class.perform_async
  #   assert_equal :scheduled, described_class.queue
  # end

  # it 'goes into the jobs array for testing environment' do
  #   expect do
  #     described_class.perform_async
  #   end.to change(described_class.jobs, :size).by(1)
  # end

  pending 'EventWorker Specs'
end
