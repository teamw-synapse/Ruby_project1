class AddFieldExcludeTagToCommisionSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_commission_settings, :exclude_tag, :string
  end
end
