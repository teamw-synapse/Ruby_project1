# frozen_string_literal: true

module Spree
  module Products
    class NetsuitePropagator
      attr_reader :product, :script_id

      def initialize(product:)
        @product = product
        @script_id = Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:PRODUCT][:NETSUITE_SYNC_UPDATES]
      end

      def payload_for(product)
        { payload_id: product.payload_id }
      end

      def send_to_netsuite(arg_def = :data)
        ns_request = SuiteRest::RestService.new(type: :post,
                                                script_id: script_id,
                                                deploy_id: 1,
                                                args_def: [arg_def])
        begin
          payload = payload_for(product)
          puts "===IN SENDING DATA TO NETSUITE---> #{payload}"
          result = ns_request.call(data: payload)
          product.update(payload_id: result['payload_id']) if result['success'] &&
                                                              result['netsuite_id']&.present?
          process_response(result, product) if result['success']
        rescue StandardError => e
          puts "---i am in error--#{e.message}"
          return false
        end
        result
      end

      def process_response(result, product)
        return unless result['success']

        product.update(netsuite_id: result['netsuite_id'].to_i, netsuite_synced: true)
        product.variants_including_master.each do |variant|
          if variant.is_master?
            variant.update(netsuite_id: result['netsuite_id'].to_i, netsuite_synced: true)
          else
            net_id = result['variants'].find { |r| r['sku'].eql?(variant.sku) }['netsuite_id']
            variant.update(netsuite_id: net_id.to_i, netsuite_synced: true)
          end
        end
      end
    end
  end
end
