class AddShopifyOrderNumberToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_orders, :shopify_order_number, :string
    add_index :spree_orders, :shopify_order_number
  end
end
