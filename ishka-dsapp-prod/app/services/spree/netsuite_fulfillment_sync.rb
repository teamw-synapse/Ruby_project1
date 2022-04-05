# frozen_string_literal: true

module Spree
  class NetsuiteFulfillmentSync
    attr_reader :order, :delta

    def initialize(delta: 80, order:)
      @delta = delta
      @order = order
    end

    def formated_result
      return unless order.netsuite_id.present?

      fulfillment_hash = { date: Date.today, netsuite_order_id: order.netsuite_id }
      lines = {}
      line_items = []
      order.shipments.each do |shipment|
        next unless shipment.stock_location.netsuite_synced?

        line_items = []

        shipment.inventory_units.uniq(&:variant_id).each do |i_unit|
          line_items.push(
            variant_netsuite_id: i_unit.variant.netsuite_id,
            sku: i_unit.variant.barcode,
            quantity: find_total_qty(i_unit.variant_id, shipment)
          )
        end
        lines[:line_item_attributes] = line_items
        lines[:tracking] = shipment.tracking
        lines[:tracking_url] = shipment.tracking_url
        lines[:location_netsuite_id] = shipment.stock_location.netsuite_id
        fulfillment_hash.merge!(lines)
        send_to_netsuite(fulfillment_hash, shipment) if fulfillment_hash.present?
      end
    end

    def find_total_qty(variant_id, shipment)
      shipment.inventory_units.where(variant_id: variant_id)
              .inject(0) { |counter, (item, _qty)| counter + item.quantity }
    end

    def send_to_netsuite(fulfillment_hash, shipment)
      arg_def = :data
      script_id = Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:FULLFILLMENT][:CREATE]
      ns_request = SuiteRest::RestService.new(type: :post,
                                              script_id: script_id,
                                              deploy_id: 1,
                                              args_def: [arg_def])
      begin
        result = ns_request.call(data: fulfillment_hash)
        shipment.update_column(:netsuite_synced, true) if result['success']
      rescue StandardError => e
        puts "---i am in error--#{e.message}"
      end
      result
    end
  end
end
