# frozen_string_literal: true

# This module was implemented to DRY up api controllers with search feature.
# After initialization it will append params handling helpers which are more or
# less generic for all search controllers currently.
#
# * search_params  - permits search related params
# * filter_params  - extracted filter params
# * query_param    - query string
# * sorting_params - takes params from request or sets to default
# * page_param     - "
# * per_page_param - "
# * set_search_headers - sets X- parameters in response header
#
# Usage example:
# class SomeController << SomeParentController
#   has_search_params defaults: { sort: 'field', order: 'desc', per_page: 1 },
#                     filters: %i[ filter_id another_filter_id ]
#
#   def index
#     data = SomeMode.custom_search(query_param, filter_params)
#                    .order(sorting_params)
#                    .page(page_param)
#                    .per(per_page_param)
#                    .preload
#
#     set_search_headers(data)
#
#     render json: data.load
#   end
# end
#
module Spree
  module Search::Params
    extend ActiveSupport::Concern

    module ClassMethods
      def has_search_params(options = {})
        default = options.fetch(:defaults, {})
        filters = options.fetch(:filters, [])

        define_method :search_params do
          list = %i[query sort order page per_page] + filters
          params.permit(*list)
        end

        define_method :filter_params do
          search_params.extract!(*filters)
        end

        define_method :query_param do
          search_params.fetch(:query, '')
        end

        define_method :sort_param do
          search_params.fetch(:sort, default[:sort] || 'name')
        end

        define_method :order_param do
          search_params.fetch(:order, default[:order] || 'asc')
        end

        define_method :sorting_params do
          { sort_param + '.sort' => order_param }
        end

        define_method :page_param do
          search_params.fetch(:page, 1)
        end

        define_method :per_page_param do
          search_params.fetch(:per_page, default[:per_page] || 2000)
        end

        define_method :set_search_headers do |collection|
          response.headers['X-Total-Count'] = collection.total_count.to_s
          response.headers['X-Page-Number'] = page_param.to_s
          response.headers['X-Per-Page']    = per_page_param.to_s
          response.headers['X-Page-Sort']   = sort_param
          response.headers['X-Page-Order']  = order_param
        end
      end
    end
  end
end
