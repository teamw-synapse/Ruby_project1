# frozen_string_literal: true

class CommissionSyncJob < ApplicationJob
  queue_as :commission_sync_queue

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts exception.inspect
  end

  def perform
    Spree::Vendor.find_each do |vend|
      vend.commission_settings.each do |cs|
        cc = CommissionSync.new(commission_setting: cs)
        cc.start
      rescue StandardError => e
        puts "::Error:: ProcessCommissionOnProductPricesJob while processing #{commission_setting.id}----> #{e.message}"
      end
    end
  end
end
