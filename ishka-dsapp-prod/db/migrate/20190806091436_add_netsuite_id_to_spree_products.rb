class AddNetsuiteIdToSpreeProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_products, :netsuite_id, :integer
    add_column :spree_products, :netsuite_synced, :boolean, default: false
    add_index :spree_products, :netsuite_id
  end
end
