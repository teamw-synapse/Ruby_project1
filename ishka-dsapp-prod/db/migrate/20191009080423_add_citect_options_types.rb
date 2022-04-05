class AddCitectOptionsTypes < ActiveRecord::Migration[5.2]
  def change
  enable_extension :citext
  change_column :spree_option_types, :name, :citext
  end
end
