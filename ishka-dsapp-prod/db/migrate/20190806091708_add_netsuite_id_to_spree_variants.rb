class AddNetsuiteIdToSpreeVariants < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_variants, :netsuite_id, :integer
    add_column :spree_variants, :netsuite_synced, :boolean, default: false
    add_index :spree_variants, :netsuite_id
  end
end
