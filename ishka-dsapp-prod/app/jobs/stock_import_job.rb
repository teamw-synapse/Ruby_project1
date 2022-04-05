# frozen_string_literal: true

class StockImportJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :stock_import_queue

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts exception.inspect
  end

  def perform(process_request)
    file_url = url_for(process_request.request_file)
    loader = DataShift::SpreeEcom::StockLoader.new(file_url, {}, user: process_request.user)
    file_name = loader.run
    file_path = Rails.root.to_s.concat("/#{file_name}")
    file = File.new(file_path)
    process_request.response_file.attach(io: file,
                                         filename: 'response_file.csv',
                                         content_type: 'text/csv')
    process_request.update(processed: true)
    ImportJobNotifierMailer.notify_stock_import(process_request, process_request.user)
                           .deliver_now
    file.close
    File.delete(file_path) if File.exist?(file_path)
  rescue StandardError => e
    puts "::Error:: @StockImportJob while processing #{process_request.id}----> #{e.message}"
  end
end
