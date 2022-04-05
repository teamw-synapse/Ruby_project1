class ResetCommissionPriceJob < ApplicationJob
  queue_as :product_commission_queue

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts exception.inspect
  end

  def perform(commission_setting)
    cc = CommissionCalculation.new(commission_setting: commission_setting)
    cc.change_offset(delete: true)
    commission_setting.destroy
  rescue StandardError => e
    puts "::Error:: ProcessCommissionOnProductPricesJob while processing #{commission_setting.id}----> #{e.message}"
  end
end
