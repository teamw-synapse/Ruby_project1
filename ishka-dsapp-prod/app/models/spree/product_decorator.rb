# frozen_string_literal: true

Spree::Product.class_eval do
  include Spree::Search::Product
  scope :with_tag, ->(name) { eager_load(:tags).where(spree_tags: { name: name.downcase }) }
  scope :with_category, ->(name) { eager_load(:taxons).where(spree_taxons: { name: name.downcase }) }
  scope :to_be_sync_products, -> { where(approved: true, payload_id: nil).where.not(commission_price: nil) }
  scope :with_pending_netsuite_ids, -> { where.not(payload_id: nil).where(netsuite_id: nil, netsuite_synced: false) }

  has_one :commission_product, dependent: :destroy
  has_one :commission_setting, through: :commission_product

  after_commit :send_to_netsuite_for_update
  before_validation :set_ishka_sku, on: :create

  def to_netsuite_json(update: false)
    app = Rails.application.routes.url_helpers
    attr = %w[name description available_on slug meta_description meta_keywords promotionable meta_title tag_list]
    img_attr = %w[alt]
    payload = attributes.slice(*attr)
    payload['netsuite_id'] = netsuite_id if update
    payload['tags'] = tags.pluck(:name).join(', ')
    payload['sku'] = barcode
    payload['class'] = taxons&.first&.name
    payload['category'] = taxons&.first&.name
    payload['taxable'] =  true
    payload['display_price'] = "$#{price_with_commission}"
    payload['total_on_hand'] = total_on_hand
    payload['cost_price'] = price
    payload['barcode'] = sku
    payload['variants'] = []
    vrnts = variants_including_master.eager_load(:images, option_values: :option_type)
    vrnts.each do |variant|
      v_hash = variant.attributes.slice('weight', 'height', 'width', 'depth', 'track_inventory')
      v_hash['netsuite_id'] = variant.netsuite_id if update
      v_hash['name'] = variant.name
      v_hash['sku'] = variant.barcode
      v_hash['barcode'] = variant.sku
      v_hash['is_master'] = variant.is_master?
      v_hash['price'] = variant.price_with_commission
      v_hash['cost_price'] = variant.cost_price
      v_hash['slug'] = variant.slug
      v_hash['description'] = variant.description
      v_hash['cost_price'] = variant.price.to_f
      v_hash['option_values'] = variant.option_values.map do |o|
        { 'option_type_name': o.option_type.name,
          'option_type_id': o.option_type.option_value_netsuite_mapping,
          'name': o.name,
          'presentation': o.presentation }
      end
      v_hash['images'] = variant.images.each_with_index.map do |i, index|
        i.attributes.slice(*img_attr)
         .merge(position: index + 1)
         .merge(i.attachment.metadata.slice('width', 'height'))
         .merge(attachment_url: app.rails_blob_url(i.attachment))
      end
      v_hash['display_price'] = "$#{variant.price_with_commission}"
      v_hash['options_text'] = variant.options_text
      v_hash['in_stock'] = variant.in_stock?
      v_hash['is_backorderable'] = variant.is_backorderable?
      v_hash['is_orderable'] = v_hash['in_stock']
      v_hash['total_on_hand'] = variant.total_on_hand
      payload['variants'].push v_hash 
    end
    payload['vendor_id'] = vendor&.netsuite_id
    payload['vendor_name'] = vendor.name
    payload
  end

  def should_update_on_netsuite?
    return false unless approved && commission_price.present?

    tracked_keys = %w[name description slug meta_description
                      meta_keywords tag_list price sku barcode
                      images]
    saved_changes.keys.map { |k| tracked_keys.include?(k) }.any?
  end

  def price_with_commission
    commission_price || price.to_f
  end

  def send_to_netsuite_for_update
    ProductUpdateProcessorJob.perform_later(self) if should_update_on_netsuite?
    ProductUpdateProcessorJob.perform_later(self, payload_sync: false) unless netsuite_id.present?
  end

  def set_ishka_sku
    return unless vendor.present?

    self.barcode = (vendor.sku_prefix + '-' + sku).strip
  end
end
