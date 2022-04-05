module Spree
  module StockLocations
    class NetsuiteIntegration
      attr_reader :stock_location, :update_req

      def initialize(stock_location:, update_req: false)
        @stock_location = stock_location
        @update_req = update_req
      end

      def payload
        stock_location.to_netsuite_json(update: update_req)
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

        stock_location.update(netsuite_id: result['netsuite_id'].to_i, netsuite_synced: true)
      end
    end
  end
end
