class AddNetsuiteDetailsToSpreeStockLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_stock_locations, :netsuite_synced, :boolean
    add_column :spree_stock_locations, :netsuite_id, :integer
    add_index :spree_stock_locations, :netsuite_id
  end
end
