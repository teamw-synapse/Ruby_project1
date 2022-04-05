# frozen_string_literal: true

require 'spree'
require 'spree_loading'
require 'open-uri'

module DataShift
  module SpreeEcom
    class StockLoader
      include SpreeLoading

      attr_accessor :file_name, :user, :csv_file
      # attr_accessor :datashift_loader

      # delegate :loaded_count, :failed_count, :processed_object_count, to: :datashift_loader
      # delegate :configure_from, to: :datashift_loader

      def initialize(file_name, options = {}, user:)
        @file_name = get_local_file_path(file_name)
        @options = options
        @user = user
        # @datashift_loader = DataShift::Loader::Factory.get_loader(file_name)
      end

      def force_inclusion_columns
        @force_inclusion_columns ||= %w[ sku
                                         location_name
                                         active
                                         count_on_hand
                                         backorderable]
      end

      def validate_file
        return unless @file_name.present?

        converter = ->(header) { header.downcase }
        @csv_file = CSV.read(file_name, headers: true, header_converters: converter)
        headers = @csv_file.first.to_h.keys.map(&:downcase)
        valid = !(force_inclusion_columns - headers).present?
        error = valid ? '' : 'Missing the required columns'
        [valid, error]
      end

      def scoped_variant
        @scoped_variant ||= if user.respond_to?(:has_spree_role?) && user.has_spree_role?(:admin)
                              Spree::Variant
                            else
                              u = user.class.eql?(Spree::User) ? user.vendors.first : user
                              u.variants
                            end
      end

      def get_local_file_path(file_url)
        return file_url unless is_url?(file_url)

        RemoteToLocalResource.new(URI.parse(file_url)).file.open
      end

      def scoped_location
        @scoped_location ||= if user.respond_to?(:has_spree_role?) && user.has_spree_role?(:admin)
                               Spree::StockLocation
                             else
                               u = user.class.eql?(Spree::User) ? user.vendors.first : user
                               u.stock_locations
                             end
      end

      def is_url?(url_string)
        URI.parse(url_string).host.present?
      end

      def remove_local_copy
        File.delete(file_name) if File.exist?(file_name)
      end

      def run
        valid, error = validate_file
        return error unless valid

        logger.warn "Stock Details load from File [#{file_name}]"
        record_processed = 0
        response_file_name = "tmp/response_file_#{DateTime.now.to_i}.csv"
        headers = force_inclusion_columns.push('Error', 'Error Detail')
        CSV.open(response_file_name, 'wb', write_headers: true, headers: headers) do |csv|
          @csv_file.each do |detail|
            unless detail['sku'].present?
              csv << detail.to_h.values.push('YES', 'Skipped due to Missing sku')
              next
            end
            variant = scoped_variant.find_by(sku: detail['sku'].downcase.strip)
            unless variant.present?
              csv << detail.to_h.values.push('YES', "COULD NOT SAVE :: - ERRORS :: #{detail['sku']} not found")
              logger.warn "COULD NOT SAVE :: #{detail.inspect} ERRORS :: #{detail['sku']} not found"
              next
            end
            location = scoped_location.find_or_initialize_by(name: detail['location_name'].strip&.downcase)
            if location.new_record?
              location.country = Spree::Country.default
              location.vendor_id = variant.vendor_id
              location.save
            end
            stock_item = variant.stock_items.find_or_initialize_by(stock_location_id: location.id)
            qty = valid_qty_for_movement(stock_item, detail['count_on_hand'])
            stock_movement = location.stock_movements.build(quantity: qty)
            stock_movement.stock_item = stock_item
            stock_movement.originator = user
            if stock_movement.save
              record_processed += 1
              csv << detail.to_h.values.push('-', '-')
            else
              csv << detail.to_h.values.push('YES', "COULD NOT SAVE :: #{detail.inspect} ERRORS :: #{stock_item.errors.full_messages}")
              logger.warn "COULD NOT SAVE :: #{detail.inspect} ERRORS :: #{stock_item.errors.full_messages}"
            end
          end
        end
        logger.warn "TOTAL PROCESSED RECORDS :: #{record_processed}"
        remove_local_copy
        response_file_name
      end

      private

      def valid_qty_for_movement(stock_item, csv_qty)
        return csv_qty if stock_item.new_record?

        csv_qty.to_i - stock_item.count_on_hand
      end
    end
  end
end
