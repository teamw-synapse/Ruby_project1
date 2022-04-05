# frozen_string_literal: true

class FulfillmentSyncJob < ApplicationJob
  queue_as :fulfillment_sync

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts exception.inspect
  end

  def perform(order:)
    fulfillment_sync = Spree::NetsuiteFulfillmentSync.new(order: order)
    fulfillment_sync.formated_result
  rescue StandardError => e
    puts '::Error:: while processing fulfillment_sync'
    puts "--> #{e.message}"
  end
end
