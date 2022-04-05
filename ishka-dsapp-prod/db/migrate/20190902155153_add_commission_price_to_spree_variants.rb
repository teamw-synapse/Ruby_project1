class AddCommissionPriceToSpreeVariants < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_variants, :commission_price, :float
  end
end
