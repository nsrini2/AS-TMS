module LocalTire
  module ActiveModel
    module Extensions
      def per_page(val)
        @per_page = val
      end
  
      def search_indexes(*vals)
        @search_indexes = vals.map {|val| val.to_s}
      end
  
      def get_per_page
        @per_page || 10
      end
  
      def get_search_indexes
        @search_indexes || []
      end
      
      def get_page(page=1)
        page = page.to_i
        page > 1 ? page : 1
      end
  
      class EmptyResultSet < Array
        def total_entries; 0; end
        def total_pages; 0; end
      end
  
      def generate_mock_results
        EmptyResultSet.new
      end
    end
  end
end