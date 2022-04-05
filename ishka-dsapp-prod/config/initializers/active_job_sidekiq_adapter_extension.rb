# frozen_string_literal: true

# This patch allows to use 'sidekiq_options' inside ActiveJob jobs
module ActiveJobSidekiqAdapterExtension
  def enqueue(job)
    inject_sidekiq_options(job)
    super
  end

  def enqueue_at(job, timestamp)
    inject_sidekiq_options(job)
    super
  end

  private

  def inject_sidekiq_options(job)
    return unless job.sidekiq_options_hash
    ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.sidekiq_options(job.sidekiq_options_hash)
  end
end

module ActiveJob
  module QueueAdapters
    class SidekiqAdapter
      prepend ActiveJobSidekiqAdapterExtension
    end
  end

  class Base
    class_attribute :sidekiq_options_hash

    def self.sidekiq_options(opts = {})
      self.sidekiq_options_hash = opts
    end
  end
end
