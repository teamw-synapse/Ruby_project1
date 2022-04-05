# frozen_string_literal: true

Spree::Vendor.class_eval do
  validates :sku_prefix, uniqueness: true, allow_blank: true
  ## Associations ##
  has_many :commission_settings, class_name: 'Spree::CommissionSetting',
                                 dependent: :destroy, foreign_key: 'spree_vendor_id'

  has_many :order_requests, dependent: :destroy

  after_commit :send_to_netsuite_for_create, on: :create
  after_commit :send_to_netsuite_for_update, on: :update

  before_validation :set_sku_prefix, on: :create

  def to_netsuite_json(update: false)
    payload = attributes.slice('notification_email', 'name', 'state', 'slug', 'about_us', 'contact_us')
    payload['netsuite_id'] = netsuite_id if update
    payload
  end

  def set_sku_prefix
    self.sku_prefix = generate_prefix
  end

  def commission_qualifying_values(key)
    if key.casecmp('sku').zero?
      products.eager_load(:master).select(:sku).pluck(:sku)
    elsif key.casecmp('tags').zero?
      products.joins(:tags).select('spree_tags.name AS sname').map(&:sname).uniq
    else
      products.joins(:taxons).select('spree_taxons.name AS tname').map(&:tname).uniq
    end
  end

  def send_to_netsuite_for_create
    vendor_intg = Spree::Vendors::NetsuiteIntegration.new(vendor: self)
    vendor_intg.send_to_netsuite(Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:VENDOR][:CREATE])
  end

  def send_to_netsuite_for_update
    valid_keys = previous_changes.keys - %w[netsuite_id netsuite_synced updated_at]
    return unless valid_keys.present?

    puts 'Updating Vendor NETSUITE!'
    vendor_intg = Spree::Vendors::NetsuiteIntegration.new(vendor: self, update_req: true)
    vendor_intg.send_to_netsuite(Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:VENDOR][:UPDATE])
  end

  private

  def generate_prefix
    (2...(name.length)).map { |i| name[0..i].gsub(/\s+/, '') }.each do |token|
      break token unless Spree::Vendor.where(sku_prefix: token).exists?
    end
  end
end
