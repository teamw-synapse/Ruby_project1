# frozen_string_literal: true

Spree::StockLocation.class_eval do
  validates_length_of :name, minimum: 5, maximum: 31, allow_blank: false
  ## Scopes ##
  scope :recently_updated_stocks, lambda { |delta: 80|
    eager_load(stock_items: [:stock_movements, variant: :product])
      .where(spree_products: { approved: true, netsuite_synced: true }, spree_variants: {netsuite_synced: true})
      .where('spree_stock_movements.updated_at >= ?', Time.current - delta.minutes)
  }

  ## Callbacks ##
  after_commit :send_to_netsuite_for_create, on: :create
  after_commit :send_to_netsuite_for_update, on: :update

  def to_netsuite_json(update: false)
    payload = attributes.except('id', 'updated_at', 'state_id', 'country_id',
                                'propagate_all_variants', 'vendor_id',
                                'netsuite_synced', 'netsuite_id')
    payload['netsuite_vendor_id'] = vendor&.netsuite_id
    payload['netsuite_id'] = netsuite_id if update
    payload
  end

  def send_to_netsuite_for_create
    intg = Spree::StockLocations::NetsuiteIntegration.new(stock_location: self)
    intg.send_to_netsuite(Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:LOCATION][:CREATE])
  end

  def send_to_netsuite_for_update
    valid_keys = previous_changes.keys - %w[netsuite_id netsuite_synced updated_at]
    return unless valid_keys.present?

    puts 'Updating Stock Location NETSUITE!'
    intg = Spree::StockLocations::NetsuiteIntegration.new(stock_location: self, update_req: true)
    intg.send_to_netsuite(Rails.application.credentials[Rails.env.to_sym][:NETSUITE_SCRIPTS][:LOCATION][:UPDATE])
  end
end
