module Microreview
  class Review
  
    class << self
      
      def find(params={})
        json = RestClient.get 'https://microreviews-test.cubeless.com/microreviews.json', {:params => params, :accept => :json}
        hash = JSON.parse(json)
      end
      
      def find_by_id(id, params={})
        json = RestClient.get "https://microreviews-test.cubeless.com/microreviews/#{id}.json", {:params => params, :accept => :json}
        hash = JSON.parse(json)
      end
      
      # def find_aggregate_by_reviewable_type(reviewable_type)
      #   json = RestClient.get 'https://microreviews-test.cubeless.com/microreviews.json', {:params => { :reviewable_type => reviewable_type, :aggregate => true }, :accept => :json}
      # end
      
      def create(attributes={})
        json = RestClient.post "https://microreviews-test.cubeless.com/microreviews.json", attributes.to_json, :content_type => :json, :accept => :json
        json
      end
      
      def update(id, attributes={})
        json = RestClient.put "https://microreviews-test.cubeless.com/microreviews/#{id}.json", attributes.to_json, :content_type => :json, :accept => :json
        json
      end
      
      def destroy(id, api_key)
        json = RestClient.delete "https://microreviews-test.cubeless.com/microreviews/#{id}.json?api_key=#{api_key}", :content_type => :json, :accept => :json
        json
      end
      
    end
  
  end
end