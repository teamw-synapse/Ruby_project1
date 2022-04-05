# frozen_string_literal: true

class CommissionCalculation
  attr_reader :commission_setting, :rate, :qualifyed_products

  def initialize(commission_setting:)
    @commission_setting = commission_setting
    @rate = @commission_setting.rate
  end

  def price_with_commission(object, active)
    # #1.1 is for gst, which is static now for au
    # pretty price rule <50 set after gst to .99 format
    # > 50 set to next .0
    price = object.price.to_f
    return price unless active

    return rate if commission_setting.flat_price?

    price += (rate.to_f / 100 * price)

    price.round(2)

    #return (((price * 1.1).ceil.to_f - 0.01) / 1.1).round(2) if price <= 50.0

    #((price * 1.1).ceil.to_f / 1.1).round(2)
  end

  def start_sync
    commission_products = []
    commission_setting.qualifyed_products(new_settings: true).each do |product|
      commission_products << manage_commission_product(product)
      propogate_price(product)
    end
    Spree::CommissionProduct.import commission_products, validate: true, on_duplicate_key_ignore: true
  end

  def change_offset(delete: false)
    active = delete ? false : commission_setting.status
    commission_setting.qualifyed_products.each do |product|
      propogate_price(product, active: active)
    end
  end

  def manage_commission_product(product)
    commission_setting.commission_products.build(product_id: product.id)
  end

  def propogate_price(product, active: true)
    product.variants_including_master.find_each do |variant|
      puts "updating for --#{product.id} -- variants #{variant.id}"
      variant.update(commission_price: price_with_commission(variant, active))
    end
    puts "updating for --#{product.id} --"
    product.update(commission_price: price_with_commission(product, active))
  end
end
