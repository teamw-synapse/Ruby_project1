# frozen_string_literal: true

class ProductIndex < Chewy::Index
  settings analysis: {
    normalizer: {
      sort: {
        type: 'custom',
        token_filter: %w[trim],
        filter: %w[lowercase]
      }
    }
  }
  define_type Spree::Product.includes(:tags, :taxons) do
    field :tags, type: 'text', analyzer: 'standard', value: -> { tags.collect { |t| t.name.downcase } } do
      field :sort, type: 'keyword'
    end

    field :vendor_id, type: 'keyword'
    field :price, type: 'half_float'
    field :commission_price, type: 'half_float'
    field :id, type: 'integer'
    field :taxons, type: 'text', analyzer: 'standard', value: -> { taxons.collect { |t| t.name.downcase } } do
      field :sort, type: 'keyword'
    end
  end
end
