# frozen_string_literal: true

module Spree
  module Api
    module V1
      class OrdersRequestController < Spree::Api::BaseController
        def create
          if params[:order].present? && params[:order][:vendor_id].present? && find_vendor.present?
            vendor = find_vendor
            order_req = vendor.order_requests.build(request_data: params[:order])
            if order_req.save
              render json: { result: { messages: 'Order Request Accepted Successfully!', request_no: order_req.id, errorcode: 200 } }.to_json
            else
              render json: { result: { messages: 'Invalid Parameters', errorcode: 404 } }.to_json
            end
          else
            render json: { result: { messages: 'Invalid Parameters', errorcode: 404 } }.to_json
          end
        end

        private

        def find_vendor
          Spree::Vendor.find_by(netsuite_id: params[:order][:vendor_id].to_i)
        end
      end
    end
  end
end
