# frozen_string_literal: true

class ProductUpdateProcessorJob < ApplicationJob
  queue_as :product_update_queue

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts exception.inspect
  end

  def perform(product, payload_sync: true)
    integration_service = if payload_sync
                            Spree::Products::NetsuiteIntegration.new(product: product)
                          else
                            Spree::Products::NetsuitePropagator.new(product: product)
                          end
    integration_service.send_to_netsuite
  rescue StandardError => e
    puts "::Error:: #{e.message}"
  end
end
