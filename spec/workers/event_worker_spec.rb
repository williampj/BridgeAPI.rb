require_relative './spec_helper'

RSpec.describe EventWorker, type: :worker do
  # it 'Event jobs are enqueued in the scheduled queue' do
  #   described_class.perform_async
  #   assert_equal :scheduled, described_class.queue
  # end

  # it 'goes into the jobs array for testing environment' do
  #   expect do
  #     described_class.perform_async
  #   end.to change(described_class.jobs, :size).by(1)
  # end

  pending 'can process an event'
  pending 'can retry 3 times'
  pending 'can clean up when errors are raised'
end
