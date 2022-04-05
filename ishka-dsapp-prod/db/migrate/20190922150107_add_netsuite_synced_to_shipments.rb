class AddNetsuiteSyncedToShipments < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_shipments, :netsuite_synced, :boolean, default: false
  end
end
