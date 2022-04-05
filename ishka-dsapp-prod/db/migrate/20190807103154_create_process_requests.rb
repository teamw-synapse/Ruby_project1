class CreateProcessRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :process_requests do |t|
      t.string :process_type
      t.boolean :processed, default: false
      t.integer :spree_user_id
      t.timestamps
    end
    add_index :process_requests, :process_type
    add_index :process_requests, :spree_user_id
  end
end
