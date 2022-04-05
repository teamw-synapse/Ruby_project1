# frozen_string_literal: true

class CommissionSync < CommissionCalculation
  def start
    products_to_remove_from_commission
    start_sync
  end

  def products_to_remove_from_commission
    not_valid_products_id = commission_setting.commission_products.pluck(:product_id) -
                            commission_setting.qualifyed_products(new_settings: true, ignore_prodcuts: false).pluck(:id)
    not_valid_commission_products = commission_setting
                                    .commission_products.where(product_id: not_valid_products_id)
    not_valid_commission_products.each do |commission_product|
      propogate_price(commission_product.product, active: false)
    end
    not_valid_commission_products.destroy_all
  end
end
