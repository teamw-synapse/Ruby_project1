# frozen_string_literal: true

module Spree
  module Products
    class NetsuiteIntegration
      attr_reader :product, :update_req, :script_id

      def initialize(product:)
        @product = product
        @update_req = product.netsuite_synced
        @script_id = if update_req
                       Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:PRODUCT][:UPDATE]
                     else
                       Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:PRODUCT][:CREATE]
                     end
      end

      def payload
        product.to_netsuite_json(update: update_req)
      end

      def send_to_netsuite(arg_def = :data)
        puts "===IN SENDING DATA TO NETSUITE---> #{payload['id']}"
        return if !update_req && !product.commission_price.present?

        ns_request = SuiteRest::RestService.new(type: :post,
                                                script_id: script_id,
                                                deploy_id: 1,
                                                args_def: [arg_def])
        begin
          result = ns_request.call(data: payload)
          product.update(payload_id: result['payload_id']) if result['success']
        rescue RuntimeError => e
          puts "---i am in error--#{e.message}"
          return false
        end
        result
      end
    end
  end
end
