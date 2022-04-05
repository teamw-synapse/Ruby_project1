# frozen_string_literal: true

module Spree
  module Vendors
    class NetsuiteIntegration
      attr_reader :vendor, :update_req

      def initialize(vendor:, update_req: false)
        @vendor = vendor
        @update_req = update_req
      end

      def payload
        vendor.to_netsuite_json(update: update_req)
      end

      def send_to_netsuite(script_id, arg_def = :data)
        puts "===IN SENDING DATA TO NETSUITE---> #{payload['id']}"
        ns_request = SuiteRest::RestService.new(type: :post,
                                                script_id: script_id,
                                                deploy_id: 1,
                                                args_def: [arg_def])
        begin
          result = ns_request.call(data: payload)
          process_response(result) if result['success']
        rescue RuntimeError => e
          puts "---i am in error--#{e.message}"
          return false
        end
        result
      end

      def process_response(result)
        return unless result['success']

        vendor.update(netsuite_id: result['netsuite_id'].to_i, netsuite_synced: true)
      end
    end
  end
end
