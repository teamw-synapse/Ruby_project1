class AddFieldsToSpreeCommissionSettings < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE mode_types AS ENUM ('percentage', 'flat_price');
    SQL
    add_column :spree_commission_settings, :mode, :mode_types, default: 'percentage', null: false
  end
  def down
    remove_column :spree_commission_settings, :mode
    execute <<-SQL
      DROP TYPE mode_types;
    SQL
  end
end
