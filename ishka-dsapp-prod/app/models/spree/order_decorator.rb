# frozen_string_literal: true

Spree::Order.class_eval do
  belongs_to :order_request
  belongs_to :vendor
  scope :recently_completed_shipments, lambda { |delta: 80|
    eager_load(shipments: [:stock_location, inventory_units: :variant])
      .where.not(netsuite_id: nil)
      .where(spree_shipments: { updated_at:
        Time.current - delta.minutes..Time.current, state: 'shipped', netsuite_synced: false })
  }

  def vendor_name
    line_items.map(&:product).first.vendor.name
  end
end
