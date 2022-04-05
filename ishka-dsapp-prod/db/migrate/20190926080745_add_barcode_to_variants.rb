class AddBarcodeToVariants < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_variants, :barcode, :string
    add_column :spree_orders, :netsuite_so, :string
    add_index :spree_orders, :netsuite_so
  end
end
