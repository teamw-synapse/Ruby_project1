class AddApprovedToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_products, :approved, :boolean, default: false
  end
end
