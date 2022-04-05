# frozen_string_literal: true

# Default Chewy strategy for Sidekiq workers
module Sidekiq
  class ChewyDefaultStrategyMiddleware
    def initialize(strategy = :atomic)
      @strategy = strategy
    end

    def call(_worker, _job, _queue)
      Chewy.strategy(@strategy) { yield }
    end
  end
end
