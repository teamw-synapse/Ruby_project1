# frozen_string_literal: true

class ProcessRequest < ApplicationRecord
  ## Associations
  belongs_to :user, class_name: 'Spree::User', foreign_key: 'spree_user_id'
  has_one_attached :request_file
  has_one_attached :response_file

  ## Enum
  enum process_type: { stock_import: 'stock_import', product_import: 'product_import' }
end
