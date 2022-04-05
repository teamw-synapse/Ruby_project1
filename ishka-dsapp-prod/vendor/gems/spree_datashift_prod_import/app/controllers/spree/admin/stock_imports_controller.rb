class Spree::Admin::StockImportsController < Spree::Admin::BaseController
  def index
    @csv_table = CSV.open(DATASHIFT_CSV_FILES[:sample_stocks_file], headers: true).read if File.exists? DATASHIFT_CSV_FILES[:sample_stocks_file]
  end

  def download_sample_csv
    send_file DATASHIFT_CSV_FILES[:sample_stocks_file]
  end

  def stock_csv_import
    begin
      loader = DataShift::SpreeEcom::StockLoader.new(params[:csv_file].path, {}, user: spree_current_user)
      valid, error = loader.validate_file
      if valid
        pr = ProcessRequest.create(request_file: params[:csv_file],
                                   process_type: 'stock_import',
                                   spree_user_id: spree_current_user.id)
        StockImportJob.perform_later(pr)
        flash[:success] = 'Import Successfull'
      else
        flash[:error] = "Error: #{error}"
      end
    rescue => e
      flash[:error] = "Error: #{e.message}"
    end
    redirect_to admin_stock_imports_path
  end
end
