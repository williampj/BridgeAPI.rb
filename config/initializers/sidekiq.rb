# frozen_string_literal: true

class SidekiqMiddleware
  def call(worker, job, _queue)
    worker.retry_count = job['retry_count'] if worker.respond_to?(:retry_count)
    yield
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SidekiqMiddleware
  end

  config.redis = { url: ENV['REDIS_URL'] } if Rails.env == 'production'
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] } if Rails.env == 'production'
end
