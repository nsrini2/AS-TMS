require File.dirname(__FILE__) + '/../spec_helper'

describe Microreview::Review do
  
  it "should connect to an account" do
    pending "No authentication yet..."
  end
  
  def json
    "[{\"microreview\":{\"created_at\":\"2010-08-16T16:11:58Z\",\"updated_at\":\"2010-08-16T16:11:58Z\",\"incoming_object_type\":\"Hotel\",\"account_id\":1,\"id\":1,\"user_id\":1,\"incoming_object_id\":10,\"quote\":\"\",\"state\":true}},{\"microreview\":{\"created_at\":\"2010-08-16T16:12:20Z\",\"updated_at\":\"2010-08-16T16:12:20Z\",\"incoming_object_type\":\"Hotel\",\"account_id\":1,\"id\":2,\"user_id\":2,\"incoming_object_id\":90,\"quote\":\"I love it\",\"state\":true}},{\"microreview\":{\"created_at\":\"2010-08-16T16:12:39Z\",\"updated_at\":\"2010-08-16T16:12:39Z\",\"incoming_object_type\":\"Hotel\",\"account_id\":1,\"id\":3,\"user_id\":2,\"incoming_object_id\":10,\"quote\":\"Hate it.\",\"state\":true}}]"
  end
  
  describe "fetching" do
    describe "a collection" do
      before(:each) do
        RestClient.stub!(:get).with('http://localhost:3000/microreviews.json', {:accept => :json}).and_return(json)
      end
      it "should scope the fetch based on the account" do
        pending "No account level scoping yet"
      end
      it "should be able to get the raw json" do
        RestClient.should_receive(:get).with('http://localhost:3000/microreviews.json', {:accept => :json}).and_return(json)
        Microreview::Review.find
      end
      it "should turn the json object into microreview objects" do
        JSON.should_receive(:parse).with(json)
        Microreview::Review.find
      end
      
      describe "based on an item id" do
        it "should " do
          pending "Not yet"
        end
      end
    end

    # I think this is being move to items....
    # describe "an aggregate" do
    #   it "should scope the aggregate on the account" do
    #     pending "No account level scoping yet"
    #   end
    #   
    #   it "should find an aggregate" do
    #     # RestClient.should_receive(:)
    #     # Microreview::Review.find_aggregate_by_type("Hotel")
    #   end
    # end
  end
  
  describe "creating" do
    it "should post to the microreview service" do
      attributes = {:microreview => {:user_id => 3, :state => true, :quote => "From the API"}}
      RestClient.should_receive(:post).with("http://localhost:3000/microreviews.json", attributes.to_json, :content_type => :json, :accept => :json)
      Microreview::Review.create(attributes)
    end
    it "should post to the microreview service with item info" do
      attributes = {:item => {:account_id => 1, :external_object_type => "Hotel", :external_object_id => "10"}, 
                    :microreview => {:user_id => 3, :state => true, :quote => "From the API"}}
      RestClient.should_receive(:post).with("http://localhost:3000/microreviews.json", attributes.to_json, :content_type => :json, :accept => :json)
      Microreview::Review.create(attributes)
    end
    it "should post to the microreview service with author info" do
      attributes = {:author => {:account_id => 1, :first_name => "Mark", :external_id => "2"},
                    :item => {:account_id => 1, :external_object_type => "Hotel", :external_object_id => "10"}, 
                    :microreview => {:user_id => 3, :state => true, :quote => "From the API"}}
      RestClient.should_receive(:post).with("http://localhost:3000/microreviews.json", attributes.to_json, :content_type => :json, :accept => :json)
      Microreview::Review.create(attributes)
    end
  end
  
  describe "updating" do
    it "should put to the microreview service" do
      attributes = {:microreview => {:quote => "From the API"}}
      RestClient.should_receive(:put).with("http://localhost:3000/microreviews/21.json", attributes.to_json, :content_type => :json, :accept => :json)
      Microreview::Review.update(21, attributes)
    end
  end
  
  describe "destroying" do
    it "should put to the microreview service" do
      RestClient.should_receive(:delete).with("http://localhost:3000/microreviews/21.json?api_key=abc123", :content_type => :json, :accept => :json)
      Microreview::Review.destroy(21, "abc123")
    end
  end

  
end