# frozen_string_literal: true

module Spree
  class NetsuiteInventorySync
    attr_reader :inventories, :delta

    def initialize(delta:)
      @delta = delta
      @inventories = Spree::StockLocation.recently_updated_stocks(delta: delta)
      formated_result
    end

    def formated_result
      inventories.map do |s|
        next unless s.netsuite_id.present?

        { location_name: s.name,
          location_id: s.netsuite_id,
          variants: s.stock_items
                     .map do |i|
                       { netsuite_id: i.variant.netsuite_id,
                         sku: i.variant.barcode,
                         count_on_hand: i.count_on_hand }
                     end.reject { |c| c.nil? || c.empty? } }
      end&.compact
    end

    def send_to_netsuite
      return unless formated_result.present?

      arg_def = :data
      script_id = Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:INVENTORY][:UPDATE]
      ns_request = SuiteRest::RestService.new(type: :post,
                                              script_id: script_id,
                                              deploy_id: 1,
                                              args_def: [arg_def])

      formated_result.each do |i|
        result = ns_request.call(data: [i])
        if result['success']
          puts 'yey'
        else
          puts result.inspect
        end
      rescue RuntimeError => e
        puts "---i am in error--#{e.message}"
        return false
      end
      result
    end
  end
end
