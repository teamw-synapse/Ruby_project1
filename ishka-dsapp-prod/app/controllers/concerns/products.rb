# frozen_string_literal: true

## Product Approve and Bluk tags update
module Products
  extend ActiveSupport::Concern

  def approve_selected_products
    if can_approve_products? && params[:product_ids].present?
      p_ids = params[:product_ids].reject(&:blank?).map(&:to_i)
      products = Spree::Product.where(id: p_ids)
      products.update_all(approved: true)
      redirect_to admin_products_path, notice: 'All seclected products Approved'
    else
      redirect_to products_path, notice: 'Only Admin Can Approve Products'
    end
  end

  def add_tag_to_products
    if can_update_tags? && params[:product_ids].present?
      update_tags
      redirect_to admin_products_path, notice: 'Tags added for all qualifying products'
    else
      redirect_to admin_products_path, notice: 'No updates due to Tag Missing'
    end
  end

  def update_tags
    ProductTagUpdateJob.perform_later(current_spree_user,
                                      query_tag: params[:query_tag],
                                      add_tag: params[:tag],
                                      remove_tag: params[:remove_tag],
                                      vendor_id: params[:vendor_id])
  end

  def load_vendors
    @vendors = Spree::Vendor.order(Arel.sql('LOWER(name)'))
  end

  def approve_request?
    params[:commit].eql?('Approve Products')
  end

  def add_tag_request?
    params[:commit].eql?('Update Tags')
  end

  def can_approve_products?
    current_spree_user.present? &&
      current_spree_user.admin? &&
      params[:commit].eql?('Approve Products')
  end

  def can_update_tags?
    current_spree_user.present? &&
      params[:commit].eql?('Update Tags') &&
      params[:tag].present? ||
      params[:remove_tag].present?
  end
end
