module Microreview
  
  class Item
    
    class << self
      def find(params={})
        json = RestClient.get 'https://microreviews-test.cubeless.com/items.json', {:params => params, :accept => :json}
        hash = JSON.parse(json)
      end
      
      def find_by_id(id, params={})
        json = RestClient.get "https://microreviews-test.cubeless.com/items/#{id}.json", {:params => params, :accept => :json}
        hash = JSON.parse(json)
      end
      
      def find_by_external_type_and_external_id(external_type, external_id, params={})
        json = RestClient.get "https://microreviews-test.cubeless.com/items/#{external_type}/#{external_id}.json", {:params => params, :accept => :json}
        hash = JSON.parse(json)
      end
      
      # Creation of raw items that don't have any microreviews is not currently supported 
      # def create(attributes={})
      #   json = RestClient.post "https://microreviews-test.cubeless.com/items.json", attributes.to_json, :content_type => :json, :accept => :json
      # end
    end
    
  end
  
end