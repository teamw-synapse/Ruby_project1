# frozen_string_literal: true

sidekiq_redis_options = {
  url: "redis://#{Rails.application.credentials[Rails.env.to_sym][:REDIS_HOST]}:#{Rails.application.credentials[Rails.env.to_sym][:REDIS_PORT]}/#{Rails.application.credentials[Rails.env.to_sym][:REDIS_DB]}",
  size: Rails.application.credentials[Rails.env.to_sym][:SIDEKIQ_CONCURRENCY].to_i * 10
}

sidekiq_options = {
  concurrency: Rails.application.credentials[Rails.env.to_sym][:SIDEKIQ_CONCURRENCY].to_i,
  pidfile: Rails.application.credentials[Rails.env.to_sym][:SIDEKIQ_PIDFILE],
  queues: %w[
    stock_import_queue
    product_import_queue
    inventory_sync
    product_commission_queue
    product_update_queue
    commission_sync_queue
    product_update_queue
    chewy
    default
    mailer
    mailers
    fulfillment_sync
  ]
}

sidekiq_options[:production] = {
  concurrency: Rails.application.secrets.SIDEKIQ_CONCURRENCY.to_i
}

Sidekiq.redis = sidekiq_redis_options

Sidekiq.configure_server do |config|
  config.options.merge!(sidekiq_options)
  config.server_middleware do |chain|
    # @see lib/sidekiq/chewy_default_strategy_middleware.rb
    chain.add Sidekiq::ChewyDefaultStrategyMiddleware, :atomic
  end
end
