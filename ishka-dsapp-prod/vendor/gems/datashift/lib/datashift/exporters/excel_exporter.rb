# Copyright:: (c) Autotelik Media Ltd 2016
# Author ::   Tom Statter
# Date ::     Mar 2016
# License::   MIT
#
# Details::   Export a model to Excel '97(-2007) file format.
#
# TODO: Can we switch between .xls and XSSF (POI implementation of Excel 2007 OOXML (.xlsx) file format.)
#
#
module DataShift

  class ExcelExporter < ExporterBase

    include DataShift::Logging
    include DataShift::ColumnPacker

    include DataShift::ExcelBase

    # Optional, otherwise  uses the standard collection of Model Methods for supplied klass
    attr_accessor :data_flow_schema

    def initialize
      super
    end

    def exportable?(record)

      return true if record.is_a?(ActiveRecord::Base)

      return true if Module.const_defined?(:Mongoid) && record.is_a?(Mongoid::Document)

      false
    end

    # Creates an Excel file from list of ActiveRecord objects.
    # Supply the full path to write XLS file to, OR to access output as String,
    # rather than writing to disc, pass StringIO
    # e.g
    #       file_contents = StringIO.new
    #       exporter.export(file_contents, some_records)
    #
    def export(file, export_records, options = {})
      records = [*export_records]

      if records.blank?
        logger.warn('Excel Export - No objects supplied for export - no file written')
        return
      end

      first = records[0]

      raise(ArgumentError, 'Please supply set of ActiveRecord objects to export') unless exportable?(first)

      klass = first.class

      excel = start_excel(klass, options)

      prepare_data_flow_schema(klass) unless @data_flow_schema && @data_flow_schema.nodes.klass == klass

      headers = export_headers(klass)

      logger.info("Exporting #{records.size} #{klass} to Excel")

      excel.ar_to_xls(records, headers: headers, data_flow_schema: data_flow_schema)

      excel.auto_fit_rows.auto_fit_columns

      logger.info("Writing Excel to file [#{file}]")

      excel.write( file )

      excel
    end

    def export_headers(klass)
      headers = if(data_flow_schema)
                  data_flow_schema.headers
                else
                  Headers.klass_to_headers(klass)
                end
      excel.set_headers( headers )
      headers
    end

    def prepare_data_flow_schema(klass)
      @data_flow_schema = DataShift::DataFlowSchema.new
      @data_flow_schema.prepare_from_klass( klass )

      data_flow_schema
    end

    # Create an Excel file from list of ActiveRecord objects, includes relationships
    #
    # The Associations/relationships to include are driven by Configuration Options
    #
    #   See - lib/exporters/configuration.rb
    #
    # To export associations as JSON:
    #
    #   DataShift::Exporters::Configuration.configure { |config| config.json = true }
    #
    def export_with_associations(file_name, klass, export_records, options = {})

      records = [*export_records]

      state = DataShift::Configuration.call.with

      DataShift::Configuration.call.with = :all

      @file_name = file_name

      excel = start_excel(klass, options)

      logger.info("Processing [#{records.size}] #{klass} records to Excel")

      # TODO: - prepare_data_flow_schema here in middle of export, plus reaching through nodes to klass, does not smell right
      prepare_data_flow_schema(klass) unless @data_flow_schema && @data_flow_schema.nodes.klass == klass

      export_headers(klass)

      nodes = data_flow_schema.nodes

      row = 1

      records.each do |obj|
        column = 0

        nodes.each do |node|

          logger.info("Send to Excel: #{node.inspect}")

          model_method = node.model_method

          logger.info("Send to Excel: #{model_method.pp}")

          begin
            # pack association instances into single column
            if model_method.association_type?
              logger.info("Processing #{model_method.inspect} associations")
              excel[row, column] = record_to_column( obj.send( model_method.operator ), configuration.json? )
            else
              excel[row, column] = obj.send( model_method.operator )
            end
          rescue StandardError => x
            logger.error("Failed to write #{model_method.inspect} to Excel")
            logger.error(x.inspect)
          end

          column += 1
        end

        row += 1
      end

      logger.info("Writing Excel to file [#{file_name}]")
      excel.write( file_name )
    ensure
      DataShift::Configuration.call.with = state

    end

  end # ExcelGenerator

end # DataShift
