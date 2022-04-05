# frozen_string_literal: true

module Spree
  module Orders
    class Process
      attr_reader :order_request

      def initialize(order_request:)
        @order_request = order_request
      end

      def customer_attributes
        { firstname: customer[:first_name], lastname: customer[:last_name] }
      end

      def checkout_attributes
        { email: customer[:email] }
      end

      def shipping_attributes
        address_format(kind: 'shipping')
      end

      def billing_attributes
        address_format
      end

      def line_item_attributes
        l_items = []
        line_items.each do |l_item|
          variant_id = variant(l_item[:ds_variant_id])&.id
          next unless variant_id.present?

          l_items.push(variant_id: variant_id, quantity: l_item[:quantity])
        end
        l_items
      end

      def payment_attributes
        [{ payment_method: 'Store Credit', state: 'completed',
           amount: request_data[:total_cost] }]
      end

      def shipments_attributes
        shipments = []
        location_line_items = line_items.group_by { |l_item| l_item[:ds_location_id] }
        location_line_items.each do |l_items|
          loc = location(l_items[0])
          next unless loc.present?

          litem_sep = []
          l_items[1].each do |l_item|
            variant_id = variant(l_item[:ds_variant_id])&.id
            next unless variant_id.present?

            litem_sep.push(variant_id: variant_id, quantity: l_item[:quantity])
          end
          shipments.push(stock_location: loc.name, inventory_units: litem_sep)
        end
        shipments
      end

      def prepare_payload
        params = { completed_at: Time.now }.merge!(checkout_attributes)
        params[:bill_address_attributes] = billing_attributes
        params[:ship_address_attributes] = shipping_attributes
        params[:shipments_attributes] = shipments_attributes
        params[:line_items_attributes] = line_item_attributes
        params[:payments_attributes] = payment_attributes
        params
      end

      def import_order
        order_user = Spree::User.first
        if line_item_attributes.present?
          order = Spree::Core::Importer::Order.import(order_user, prepare_payload)
        end
        return unless order.present?

        order_request.update_attributes(order_id: order.id, order_synced: true)
        Spree::VendorMailer.vendor_notification_email(order.id, vendor(request_data[:vendor_id]).id).deliver_later
        order.update_columns(netsuite_id: request_data[:netsuite_id],
                             shopify_order_number: request_data[:weborder_id],
                             netsuite_so: request_data[:order_num], vendor_id: vendor(request_data[:vendor_id]).id )
        send_to_netsuite(order: order)
      end

      private

      def payload(order:)
        { ds_order_id: order.number, netsuite_id: order.netsuite_id, web_order_id:
           order.shopify_order_number, total_cost: order.total.to_f }
      end

      def send_to_netsuite(order:)
        arg_def = :data
        script_id = Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:ORDER][:NOTIFICATION]

        ns_request = SuiteRest::RestService.new(type: :post,
                                                script_id: script_id,
                                                deploy_id: 1,
                                                args_def: [arg_def])
        begin
          result = ns_request.call(data: payload(order: order))
        rescue RuntimeError => e
          puts "---i am in error--#{e.message}"
          return false
        end
        result
      end

      def request_data
        order_request.request_data.with_indifferent_access
      end

      def customer
        request_data[:customer]
      end

      def shipping
        request_data[:shipping_address]
      end

      def billing
        request_data[:billing_address]
      end

      def address_format(kind: 'billing')
        addr_kind = send(kind)
        address = { address1: addr_kind[:addr1], address2: addr_kind[:addr2],
                    city: addr_kind[:city], phone: addr_kind[:phone],
                    state_name: addr_kind[:state], state: { abbr: addr_kind[:state] },
                    country: { iso: addr_kind[:country] }, zipcode: addr_kind[:zip] }
        address.merge!(customer_attributes)
      end

      def line_items
        request_data[:lines]
      end

      def location(id)
        Spree::StockLocation.find_by(netsuite_id: id)
      end

      def variant(id)
        Spree::Variant.find_by(netsuite_id: id)
      end

      def vendor(id)
        Spree::Vendor.find_by(netsuite_id: id)
      end
    end
  end
end
