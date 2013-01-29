require File.dirname(__FILE__) + '/../spec_helper'

describe Microreview::Review do
  
  it "should connect to an account" do
    pending "No authentication yet..."
  end
  
  def json
    "[{\"item\":{\"external_id\":10,\"created_at\":\"2010-08-16T21:02:08Z\",\"updated_at\":\"2010-08-16T22:22:59Z\",\"account_id\":1,\"meta\":null,\"id\":1,\"microreviews_count\":7,\"external_type\":\"Hotel\",\"last_microreview_id\":11}},{\"item\":{\"external_id\":90,\"created_at\":\"2010-08-16T21:02:24Z\",\"updated_at\":\"2010-08-16T22:13:17Z\",\"account_id\":1,\"meta\":null,\"id\":2,\"microreviews_count\":1,\"external_type\":\"Hotel\",\"last_microreview_id\":null}},{\"item\":{\"external_id\":90,\"created_at\":\"2010-08-16T21:02:39Z\",\"updated_at\":\"2010-08-16T22:13:17Z\",\"account_id\":1,\"meta\":null,\"id\":3,\"microreviews_count\":1,\"external_type\":\"Book\",\"last_microreview_id\":null}},{\"item\":{\"external_id\":101,\"created_at\":\"2010-08-16T22:14:11Z\",\"updated_at\":\"2010-08-16T22:14:11Z\",\"account_id\":1,\"meta\":null,\"id\":4,\"microreviews_count\":1,\"external_type\":\"Hotel\",\"last_microreview_id\":null}}]"
  end
  
  describe "fetching" do
    describe "a collection" do
      before(:each) do
        RestClient.stub!(:get).with('http://localhost:3000/items.json', {:accept => :json, :params => {}}).and_return(json)
      end
      it "should scope the fetch based on the account" do
        pending "No account level scoping yet"
      end
      it "should be able to get the raw json" do
        RestClient.should_receive(:get).with('http://localhost:3000/items.json', {:accept => :json, :params => {}}).and_return(json)
        Microreview::Item.find
      end
      it "should turn the json object into microreview objects" do
        JSON.should_receive(:parse).with(json)
        Microreview::Item.find
      end
      it "should pass along query params" do
        RestClient.should_receive(:get).with('http://localhost:3000/items.json', {:accept => :json, :params => {:with_last_review => true}}).and_return(json)
        Microreview::Item.find(:with_last_review => true)
      end
    end

    describe "an item" do
      before(:each) do
        RestClient.stub!(:get).and_return(json)
      end
      
      describe "based on id" do
        it "should scope the fetch based on the account" do
          pending "No account level scoping yet"
        end
        it "should be able to get the raw json" do
          RestClient.should_receive(:get).with('http://localhost:3000/items/1.json', {:accept => :json, :params => {}})
          Microreview::Item.find_by_id(1)
        end
        it "should turn the json object into microreview objects" do
          JSON.should_receive(:parse).with(json)
          Microreview::Item.find_by_id(1)
        end
        it "should pass along query params" do
          RestClient.should_receive(:get).with('http://localhost:3000/items/1.json', {:accept => :json, :params => {:with_reviews => true}})
          Microreview::Item.find_by_id(1, :with_reviews => true)
        end
      end
      describe "based on external object type and external object id" do
        it "should scope the fetch based on the account" do
          pending "No account level scoping yet"
        end
        it "should be able to get the raw json" do
          RestClient.should_receive(:get).with('http://localhost:3000/items/Hotel/1.json', {:accept => :json, :params => {}})
          Microreview::Item.find_by_external_type_and_external_id("Hotel", 1)
        end
        it "should turn the json object into microreview objects" do
          JSON.should_receive(:parse).with(json)
          Microreview::Item.find_by_external_type_and_external_id("Hotel", 1)
        end
        it "should pass along query params" do
          RestClient.should_receive(:get).with('http://localhost:3000/items/Hotel/1.json', {:accept => :json, :params => {:with_reviews => true}})
          Microreview::Item.find_by_external_type_and_external_id("Hotel", 1, :with_reviews => true)
        end
      end
    end
  end

  # Currently only allowed through creating a microreview
  # describe "creating" do
  #   it "should post to the microreview service" do
  #     attributes = {:item => {:account_id => 1, :incoming_object_type => "Hotel", :incoming_object_id => "10"}, 
  #                   :microreview => {:user_id => 3, :state => true, :quote => "From the API"}}
  #     RestClient.should_receive(:post).with("http://localhost:3000/microreviews.json", attributes.to_json, :content_type => :json, :accept => :json)
  #     Microreview::Review.create(attributes)
  #   end
  # end
  

  
end