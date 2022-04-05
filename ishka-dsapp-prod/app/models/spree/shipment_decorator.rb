# frozen_string_literal: true

Spree::Shipment.class_eval do
  ## Scopes ##
  scope :recently_completed_shipments, lambda { |delta: 80|
    eager_load(:order, inventory_units: :variant)
      .where.not(spree_orders: { netsuite_id: nil })
      .where(updated_at: Time.current - delta.minutes..Time.current).shipped
  }
end
