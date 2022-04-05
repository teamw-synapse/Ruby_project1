class ImportJobNotifierMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def notify_stock_import(process_request, user)
    @user = user
    @process_request = process_request
    @url = url_for(@process_request.response_file)
    mail(to: "<#{user.email}>",
         subject: "Stock Import at Ishka/#{@process_request.created_at.strftime('%b %d %Y, %I:%M:%S %p')}",
         content_type: 'text/html')
  end

  def notify_product_import(process_request, user)
    @user = user
    @process_request = process_request
    # @url = url_for(@process_request.response_file)
    mail(to: "<#{user.email}>",
         subject: "Product Import at Ishka/#{@process_request.created_at.strftime('%b %d %Y, %I:%M:%S %p')}",
         content_type: 'text/html')
  end
end
