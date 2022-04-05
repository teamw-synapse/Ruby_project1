class AddCommissionPriceToSpreeProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_products, :commission_price, :float
  end
end
