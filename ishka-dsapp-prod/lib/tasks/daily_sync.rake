# frozen_string_literal: true

namespace :daily_sync do
  desc 'Will sync new product for payload per vendor'
  task sync_products_payload: :environment do
    Spree::Vendor.find_each do |vendor|
      products = vendor.products.to_be_sync_products
      next unless products.present?

      products.each do |product|
        puts "Added Job for - #{product.id}"
        ProductUpdateProcessorJob.perform_later(product)
      end
    end
  end

  desc 'Will sync new product per vendor with netsuite references'
  task sync_products_netsuite_details: :environment do
    Spree::Vendor.find_each do |vendor|
      products = vendor.products.with_pending_netsuite_ids
      next unless products.present?

      products.each do |product|
        puts "Added Job for - #{product.id}"
        ProductUpdateProcessorJob.perform_later(product, payload_sync: false)
      end
    end
  end
  desc 'Will sync new fulfillment'
  task sync_fulfillments: :environment do
    Spree::Order.recently_completed_shipments.each do |order|
      FulfillmentSyncJob.perform_later(order: order)
    end
  end
end
