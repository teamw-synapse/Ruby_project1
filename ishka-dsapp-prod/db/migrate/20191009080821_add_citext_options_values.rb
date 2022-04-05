class AddCitextOptionsValues < ActiveRecord::Migration[5.2]
  def change
    enable_extension :citext
    change_column :spree_option_values, :name, :citext
  end
end
