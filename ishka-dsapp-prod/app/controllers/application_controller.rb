# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def after_sign_in_path_for(_resource)
    if spree_current_user.has_spree_role?('admin')
      admin_path
    elsif spree_current_user.vendors.active.ids.any?
      admin_orders_path
    else
      root_path
    end
  end
end
