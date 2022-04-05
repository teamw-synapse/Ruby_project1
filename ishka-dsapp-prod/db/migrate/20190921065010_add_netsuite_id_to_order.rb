class AddNetsuiteIdToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_orders, :netsuite_id, :string
    add_index :spree_orders, :netsuite_id
  end
end
