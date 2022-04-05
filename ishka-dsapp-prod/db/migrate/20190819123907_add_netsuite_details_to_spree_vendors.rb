class AddNetsuiteDetailsToSpreeVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_vendors, :netsuite_synced, :boolean, default: false
    add_column :spree_vendors, :netsuite_id, :integer
    add_index :spree_vendors, :netsuite_id
  end
end
