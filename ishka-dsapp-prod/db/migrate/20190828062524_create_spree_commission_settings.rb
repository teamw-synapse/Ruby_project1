class CreateSpreeCommissionSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_commission_settings do |t|
      t.references :spree_vendor, foreign_key: true
      t.string :commission_type
      t.string :commission_value
      t.float :rate
      t.boolean :status, default: true

      t.timestamps
    end
    add_index :spree_commission_settings, :commission_type
  end
end
