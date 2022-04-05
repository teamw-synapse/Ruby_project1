module Spree
  module Admin
    class SignInAsController < Spree::Admin::BaseController
      skip_before_action :authorize_admin, only: [:destroy]
      def create
        user = Spree::User.find(params[:id])
        if !user.admin? && user.vendors.active.ids.any?
          session[:current_admin_user_id] = current_spree_user.id
          sign_in(user, bypass: true)
          redirect_to admin_orders_path, notice: "Successfully logged in as #{user.email}"
        else
          redirect_to admin_orders_path
        end
      end

      # current_admin_user? is defined on application controller, and simply checks
      # if an admin session is in process.
      def destroy
        if current_admin_user.present?
          @admin = current_admin_user
          puts @admin.inspect
          sign_in(@admin)
          session[:current_admin_user_id] = nil
          redirect_to admin_orders_path, notice: "Successfully logged in as admin [#{@admin.email}]"
        else
          sign_out(current_spree_user)
          redirect_to root_path, notice: 'Something is going wrong, please log in again'
        end
      end
    end
  end
end
