# frozen_string_literal: true

# A shared search methods to used from other Search modules
#
# This module defines easy to use wrapper around custom_search method
# Differences:
# * _search_ is convenient for traditional usage with ActionView.
#   It returns a collection
# * With _custom_search_ all power of chewy in you hand for exmaple it is
#   possible to not load objects from db at all and use indexed data for
#   performance critical places
#
module Spree
  module Search::Search
    extend ActiveSupport::Concern

    # These methods will be appended to a models
    module ClassMethods
      #
      # A simple search wrapper
      # @param query [String] A full-text search phrase
      # @param options [Hash] Optional configuration
      # @option options [Hash] filters Additional filters
      # @option options [Hash] order Sorting options
      # @option options [Fixnum] page Page number
      # @option options [Fixnum] per Per page count
      # @return [Kaminari::PaginatableArray]
      # @todo add eager loading support
      def search(query, options = {})
        scope = custom_search(query, options.fetch(:filters, {}))

        payload = scope.order(options.fetch(:order, {}))
                       .page(options.fetch(:page, 1))
                       .per(options.fetch(:per, 20))
                       .load

        # Wrapping results in Kaminari readable format
        Kaminari::PaginatableArray.new(
          payload.objects.to_a,
          limit: payload.limit_value,
          offset: payload.offset_value,
          total_count: payload.total_count
        )
      end

      protected

      # Apply filters to a query object.
      # @param scope [Chewy::Index::Query] Query object
      # @param filters [Hash] Filters hash
      # @return [Chewy::Index::Query]
      def apply_generic_filters(scope, filters)
        filters.each do |name, value|
          next if value.blank?

          terms = Array.wrap(value).map { |e| e.to_s.downcase }
          scope = scope.filter(terms: { name => terms })
        end

        scope
      end
    end
  end
end
