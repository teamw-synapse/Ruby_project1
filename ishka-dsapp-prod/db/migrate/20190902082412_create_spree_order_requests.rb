# frozen_string_literal: true

class CreateSpreeOrderRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_order_requests do |t|
      t.jsonb :request_data, default: '{}'
      t.boolean :order_synced, default: false
      t.references :order
      t.references :vendor

      t.timestamps
    end
    add_index :spree_order_requests, :request_data, using: :gin
  end
end
