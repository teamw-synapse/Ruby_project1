# frozen_string_literal: true

module Spree
  module Admin
    class CommissionSettingsController < Spree::Admin::BaseController
      before_action :authorize
      before_action :load_vendor
      before_action :load_commission_setting, only: %i[edit update destroy]

      def new
        @commission_setting = @vendor.commission_settings.build
      end

      def index
        @settings = @vendor.commission_settings
      end

      def create
        @commission_setting = @vendor.commission_settings.create(commission_setting_params)
        if @commission_setting
          redirect_to admin_commission_settings_path, notice: 'Created!'
        else
          render :new
        end
      end

      def edit; end

      def update
        @commission_setting.update(commission_setting_params)
        if @commission_setting
          redirect_to admin_commission_settings_path, notice: 'Updated!'
        else
          render :edit
        end
      end

      def destroy
        if @commission_setting.active?
          ResetCommissionPriceJob.perform_later(@commission_setting)
        else
          @commission_setting.destroy
        end
        redirect_to admin_commission_settings_path, notice: 'Your setting will be deleted soon!'
      end

      def qualifying_values
        @vendor = Spree::Vendor.find(params[:vendor_id])
        data = if @vendor.present?
                 @vendor.commission_qualifying_values(params[:key])
               else
                 []
               end
        render json: data
      end

      private

      def authorize
        authorize! :manage, :vendor_settings
      end

      def load_vendor
        @vendor = Spree::Vendor.friendly.find(params[:vendor_id])
        raise ActiveRecord::RecordNotFound unless @vendor
      end

      def load_commission_setting
        @commission_setting = @vendor.commission_settings.find(params[:id])
      end

      def commission_setting_params
        params.require(:commission_setting).permit(:id, :commission_type, :commission_value, :rate, :status, :exclude_tag, :mode)
      end
    end
  end
end
