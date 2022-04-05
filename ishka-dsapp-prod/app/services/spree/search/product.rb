# frozen_string_literal: true

# A place to define search methods for Course model
# @see Search::Search for common search case
#
module Spree
module Search::Product
  extend ActiveSupport::Concern

  included do
    include Search::Search

    update_index('product', :self)
  end

  # This methods will be appended to a model
  module ClassMethods
    #
    # @param query [String] full-text search phrase
    # @param filters [Hash] optional filters
    # @return [SectionIndex::Query]
    #
    # @see https://github.com/toptal/chewy#index-querying

    # @example custom_search( ).order( ).pre( ).per( ).preload.map(&:_object)
    # @example custom_search( ).load.to_a
    #
    #
    def custom_search(query, filters = {})
      q = query.try(:downcase).try(:squish)

      # For empty query and filters
      scope = ProductIndex.filter { match_all }

      # Applying Full-text query conditions
      if q.present? && q&.size >= 3
        scope = scope.filter do
          multi_match do
            query q
            fields %i[tags taxons]
            type 'phrase_prefix'
          end
        end
      end
      exclude_tag = filters.fetch(:exclude_tag, '')
      if exclude_tag.present?
        scope = scope.filter.not(match: { tags: exclude_tag })
        filters.delete(:exclude_tag)
      end
      apply_generic_filters(scope, filters)
    end
  end
end
end
