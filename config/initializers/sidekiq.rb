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

  if Rails.env == 'production'
    config.redis = { url: 'redis://bridgeapi-sidekiq.zocofw.0001.use2.cache.amazonaws.com:6379/0' }
  end
end

Sidekiq.configure_client do |config|
  if Rails.env == 'production'
    config.redis = { url: 'redis://bridgeapi-sidekiq.zocofw.0001.use2.cache.amazonaws.com:6379/0' }
  end
end
