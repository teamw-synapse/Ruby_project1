# frozen_string_literal: true

module Spree
  class CommissionProduct < Spree::Base
    belongs_to :product
    belongs_to :commission_setting
    ## Validations
    validates_uniqueness_of :product_id
  end
end
