# Copyright:: (c) Autotelik Media Ltd 2010 - 2012 Tom Statter
# Author ::   Tom Statter
# Date ::     Aug 2012
# License::   Free, Open Source.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# Details:: Spree Product and Image Loader from .xls or CSV
#
# To pull DataShift commands into your main Spree application :
#
#     require 'datashift_spree'
#
#     DataShift::SpreeEcom::load_commands
#
require 'rbconfig'
require 'datashift'
require 'spree'

$:.unshift '.' unless $:.include?('.')

module DataShift

  module SpreeEcom

    def self.gem_version
      unless(@gem_version)
        if(File.exists?(File.join(root_path, 'VERSION') ))
          File.read( File.join(root_path, 'VERSION') ).match(/.*(\d+.\d+.\d+)/)
          @gem_version = $1
        else
          @gem_version = '1.0.0'
        end
      end
      @gem_version
    end

    def self.gem_name
      "datashift_spree"
    end

    def self.root_path
      File.expand_path("#{File.dirname(__FILE__)}/..")
    end

    def self.library_path
      File.expand_path("#{File.dirname(__FILE__)}/../lib")
    end

    def self.require_libraries

      loader_libs = %w{ lib  }

      # Base search paths - these will be searched recursively
      loader_paths = []

      loader_libs.each {|l| loader_paths << File.join(root_path(), l) }

      # Define require search paths, any dir in here will be added to LOAD_PATH

      loader_paths.each do |base|
        $:.unshift base  if File.directory?(base)
        Dir[File.join(base, '**', '**')].each do |p|
          if File.directory? p
            $:.unshift p
          end
        end
      end

    end

    def self.require_datashift_spree

      require_libs = %w{ loaders helpers }
      require_libs.each do |base|
        Dir[File.join(library_path, base, '**/*.rb')].each do |rb|
          unless File.directory? rb
            require rb
          end
        end
      end

    end

    # Load all the datashift rake tasks and make them available throughout app
    def self.load_tasks
      # Long parameter lists so ensure rake -T produces nice wide output
      ENV['RAKE_COLUMNS'] = '180'
      base = File.join(root_path, 'tasks', '**')
      Dir["#{base}/*.rake"].sort.each { |ext| load ext }
    end

    # Load all public datashift spree Thor commands and make them available throughout app

    def self.load_commands
      base = File.join(library_path, 'tasks')

      Dir["#{base}/*.thor"].each do |f|
        next unless File.file?(f)
        Thor::Util.load_thorfile(f)
      end
    end

    def self.get_spree_class(class_name)
      "Spree::#{class_name}".constantize
    end

    def self.get_image_owner(record)
      record.is_a?(Spree::Product) ? record : record.product
    end

  end
end

DataShift::SpreeEcom::require_libraries
DataShift::SpreeEcom::require_datashift_spree

require 'datashift_spree/exceptions'
