module ActionView
  module Helpers
    module TableForHelper
    require 'enumerator'
      def table_for(collection, options, table_options=nil, row_options=nil, cell_options=nil)
        render_table_of_objects(collection, table_options) do |collection|
            render_rows_of_objects(collection, options, row_options) do |row|
              render_cells_for_objects(row, options, cell_options) do |object|
                yield object
              end
            end
          end
      end

      def render_table_of_objects(collection, table_options=nil)
        content_tag(:table, (yield collection), table_options )
      end

      def render_rows_of_objects(collection, options, row_options=nil)
        rows = ''
          collection.each_slice(options[:per_row]) do |row_of_objects|
            rows << content_tag(:tr, (yield row_of_objects), row_options )
          end
        rows
      end

      def render_cells_for_objects(collection, options, cell_options=nil)
        tds = ''
        collection.each do |object|
          tds << content_tag(:td, (yield object), cell_options )
        end
        per_row = options[:per_row]
        (collection.size%per_row+1).upto(per_row) do
          tds << content_tag(:td, '&nbsp;', cell_options)
        end if collection.size<per_row
        tds
      end
    end
  end
end

ActionView::Base.class_eval do
  include ActionView::Helpers::TableForHelper
end
