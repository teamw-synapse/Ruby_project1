# frozen_string_literal: true

class CreateSpreeCommissionProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_commission_products do |t|
      t.references :product, index: { unique: true }
      t.references :commission_setting

      t.timestamps
    end
  end
end
