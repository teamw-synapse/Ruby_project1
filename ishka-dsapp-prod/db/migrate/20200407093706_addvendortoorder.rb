# frozen_string_literal: true

class Addvendortoorder < ActiveRecord::Migration[5.2]
  def change
    add_reference :spree_orders, :vendor, index: true
    say_with_time 'add order id to existing.' do
      Spree::Order.find_each do |order|
        order.update_column(:vendor_id, order.line_items.map(&:product)&.first&.vendor&.id)
      end
    end
  end
end
