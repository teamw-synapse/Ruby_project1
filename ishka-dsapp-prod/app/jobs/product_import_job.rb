# frozen_string_literal: true

class ProductImportJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :product_import_queue

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts exception.inspect
  end

  def perform(process_request)
    file_url = url_for(process_request.request_file)
    file = RemoteToLocalResource.new(URI.parse(file_url)).file.open
    @options = { mandatory: PRODUCT_MANDATORY_FIELDS }
    loader = DataShift::SpreeEcom::ProductLoader.new(file, @options, user: process_request.user)
    loader.run
    # loader = DataShift::SpreeEcom::ProductLoader.new(params[:csv_file].path, @options, user: spree_current_user)
    # file_name = loader.run
    # file_path = Rails.root.to_s.concat("/#{file_name}")
    # file = File.new(file_path)
    # process_request.response_file.attach(io: file,
    #                                      filename: 'response_file.csv',
    #                                      content_type: 'text/csv')
    process_request.update(processed: true)
    ImportJobNotifierMailer.notify_product_import(process_request, process_request.user)
                           .deliver_now
    # file.close
    # File.delete(file_path) if File.exist?(file_path)
  rescue StandardError => e
    puts "::Error:: @ProductImportJob while processing #{process_request.id}----> #{e.message}"
  end
end
