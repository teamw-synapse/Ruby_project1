# frozen_string_literal: true

class AddSkuPrefixToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_vendors, :sku_prefix, :string
    add_index :spree_vendors, :sku_prefix, unique: true, where: 'sku_prefix IS NOT NULL'
    say_with_time 'add prefix to existing vendor' do
      Spree::Vendor.find_each do |vendor|
        prefix = (2...(vendor.name.length)).map { |i| vendor.name[0..i].gsub(/\s+/, '') }.each do |token|
          break token unless Spree::Vendor.where(sku_prefix: token).exists?
        end
        vendor.update_column(:sku_prefix, prefix)
      end
    end
  end
end
