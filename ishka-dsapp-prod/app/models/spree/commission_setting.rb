# frozen_string_literal: true

class Spree::CommissionSetting < ApplicationRecord
  ## Asociations ##
  belongs_to :vendor, class_name: 'Spree::Vendor', foreign_key: :spree_vendor_id
  has_many :commission_products, foreign_key: 'commission_setting_id', dependent: :destroy
  has_many :products, through: :commission_products

  ## Validations ##
  validates :rate, presence: true, numericality: { greater_than: 0 }
  validates :commission_value, presence: true

  ## Enum ##
  enum commission_type: { category: 'category', tags: 'tags' }
  enum mode: { percentage: 'percentage', flat_price: 'flat_price' }

  ## Callbacks ##
  after_commit :process_commission_on_products, on: :create, if: :active?
  after_commit :manage_offset_change_on_products, on: :update

  ## Instance Methods ##
  def qualifyed_products(new_settings: false, ignore_prodcuts: true)
    return products.includes(:variants_including_master) unless new_settings

    product_ids = []
    query_search = Spree::Product.custom_search(commission_value, vendor_id: spree_vendor_id)
    page = 1
    while page <= query_search.total_pages
      product_ids.push(query_search.page(page).pluck(:id))
      page += 1
    end
    product_ids = product_ids&.flatten
    product_ids = ignore_duplicated_products(product_ids) if ignore_prodcuts && new_settings
    Spree::Product.where(vendor_id: spree_vendor_id, id: product_ids)
  end

  def valid_products
    products
  end

  def process_commission_on_products
    return unless saved_change_to_rate? || saved_change_to_status?

    ProcessCommissionOnProductPricesJob.perform_later(self)
  end

  def manage_offset_change_on_products
    ManageOffsetChangeOnProductsJob.perform_later(self)
  end

  def active?
    status
  end

  private

  def ignore_duplicated_products(product_ids)
    product_ids - vendor.commission_settings.select('spree_commission_settings.*,
      spree_commission_products.id').joins(:commission_products).where(spree_commission_products: { product_id: product_ids }).pluck(:product_id)
  end
end
