# frozen_string_literal: true

class InventorySyncJob < ApplicationJob
  queue_as :inventory_sync

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts exception.inspect
  end

  def perform(delta: 80)
    inventory_sync = Spree::NetsuiteInventorySync.new(delta: delta)
    inventory_sync.send_to_netsuite
  rescue StandardError => e
    puts '::Error:: while processing Inventory Sync'
    puts "--> #{e.message}"
  end
end
