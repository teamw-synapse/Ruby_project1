# frozen_string_literal: true

class PopulateBarcodeFieldWithMasterSku < ActiveRecord::Migration[5.2]
  def change
    say_with_time 'add sku to old barcode field for existing items' do
      Spree::Product.find_each do |prod|
        prod.update_column(:barcode, prod.sku)
        prod.variants_including_master.each do |var|
          var.update_column(:barcode, var.sku)
        end
      end
    end
  end
end
