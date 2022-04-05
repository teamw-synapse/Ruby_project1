# frozen_string_literal: true

class AddUniqeIndexOnTaxonomiesPermlink < ActiveRecord::Migration[5.2]
  def change
    remove_index :spree_taxons, [:permalink]
    add_index :spree_taxons, [:permalink], unique: true
  end
end
