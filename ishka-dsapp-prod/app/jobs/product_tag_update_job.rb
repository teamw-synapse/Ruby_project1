# frozen_string_literal: true

class ProductTagUpdateJob < ApplicationJob
  queue_as :product_update_queue

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts exception.inspect
  end

  def perform(current_spree_user,query_tag:, add_tag:, remove_tag:, vendor_id:)
    product_ids = []
    query_search = if current_spree_user.has_spree_role?(:admin)
                     Spree::Product.custom_search(query_tag, vendor_id: vendor_id)
                   else
                     Spree::Product.custom_search(query_tag, vendor_id: current_spree_user.vendors.first.id)
                   end
    page = 1
    while page <= query_search.total_pages
      product_ids.push(query_search.page(page).pluck(:id))
      page += 1
    end
    products = Spree::Product.where(id: product_ids.flatten)
    add_tags = add_tag.split(',').map(&:strip)
    remove_tags = remove_tag.split(',').map(&:strip)
    products.each do |product|
      product.tag_list.add(add_tags) if add_tags.present?
      product.tag_list.remove(remove_tags) if remove_tags.present?
      product.save
    end
  end
end
