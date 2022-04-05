# frozen_string_literal: true

Spree::ProductsController.class_eval do
  include Products
  before_action :ensure_session

  def approve_products
    if approve_request?
      approve_selected_products
    elsif add_tag_request?
      add_tag_to_products
    end
  end

  private

  def ensure_session
    redirect_to products_path, notice: 'UnAuthorized' unless current_spree_user.present?
  end
end
