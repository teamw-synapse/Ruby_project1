class ChangeColumnTypesToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :spree_products, :commission_price, :decimal, :precision => 10, :scale => 2
    change_column :spree_variants, :commission_price, :decimal, :precision => 10, :scale => 2
  end
end
