# frozen_string_literal: true

module Spree
  class OrderRequest < Spree::Base
    ## Validations
    validates :request_data, presence: true # , json: true
    ## Associations
    belongs_to :vendor
    belongs_to :order
    ## callbacks
    after_commit :process_order, on: :create

    def process_order
      Spree::Orders::Process.new(order_request: self).import_order
    end
  end
end
