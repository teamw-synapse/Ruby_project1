class AddPayloadIdToSpreeProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_products, :payload_id, :integer
    add_index :spree_products, :payload_id
  end
end
