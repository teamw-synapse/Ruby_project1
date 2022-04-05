# frozen_string_literal: true

Spree::Variant.class_eval do
  after_commit :send_to_netsuite_for_update, on: :update
  after_create_commit :set_ishka_sku
  def price_with_commission
    is_master? ? product&.price_with_commission : commission_price || product&.commission_price&.to_f || price.to_f
  end

  def should_update_on_netsuite?
    return false unless product.approved && product.commission_price.present?
    return false unless product.netsuite_id.present?

    tracked_keys = %w[sku weight height width depth commission_price price updated_at images]

    saved_changes.keys.map { |k| tracked_keys.include?(k) }.any?
  end

  def send_to_netsuite_for_update
    ProductUpdateProcessorJob.perform_later(product) if should_update_on_netsuite?
  end

  def set_ishka_sku
    return unless vendor.present?

    update_column(:barcode, (vendor.sku_prefix + '-' + sku).strip)
  end
end
