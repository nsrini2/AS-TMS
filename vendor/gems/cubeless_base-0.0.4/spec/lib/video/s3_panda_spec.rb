require File.dirname(__FILE__) + '/../../spec_helper'

describe Assist::Video::S3Panda do
  class MyVideo
    include Assist::Video::S3Panda
  end
  
  before(:each) do
    @v = MyVideo.new
    
    @v.stub!(:attributes).and_return({})
    @v.stub!(:update_attribute).and_return(true)
    
    @v.stub!(:panda_video_id).and_return("PVID")
    @json = "[{\"id\":\"file\", \"extname\":\".flv\"}]"
    @json.stub!(:body).and_return(@json)
    Panda.stub!(:get).with("/videos/PVID/encodings.json").and_return(@json)
    
    @v.stub!(:akid).and_return("AKID")
    @v.stub!(:sakid).and_return("SAKID")
    @v.stub!(:bucket).and_return("BUCKET")
    @v.stub!(:s3_expiration).and_return("111")
  end
  
  it "should get the public url" do
    @v.public_s3_url.should == "https://s3.amazonaws.com/BUCKET/file.flv"
  end
  
  describe "private url" do
    it "should add the signature to the public url" do
      @v.should_receive(:signature).and_return("SIG")
      
      @v.private_s3_url.should == "https://s3.amazonaws.com/BUCKET/file.flv?AWSAccessKeyId=AKID&Signature=SIG&Expires=111"
    end
  end
  
  describe "local column caching" do
    before(:each) do
      @v.stub!(:attributes).and_return({})
    end
        
    describe "filename" do
      it "should return the filename if one exists" do
        @v.stub!(:attributes).and_return({:filename => "file1"})
        
        @v.filename.should == "file1"
      end
      
      it "should go grab the filename from the encoding data if none exists" do
        @v.should_receive(:update_attribute).with(:filename, "file").and_return(true)
        
        @v.filename.should == "file"
      end
    end
    
    describe "extname" do
      it "should return the extname if one exists" do
        @v.stub!(:attributes).and_return({:extname => ".flv"})
        
        @v.extname.should == ".flv"
      end
      
      it "should go grab the filename from the encoding data if none exists" do
        @v.should_receive(:update_attribute).with(:extname, ".flv").and_return(true)
        
        @v.extname.should == ".flv"
      end
    end
    
    describe "encoded" do
      it "should return the encoded 'true' if it's already true" do
        @v.stub!(:attributes).and_return({:encoded => true})
        
        @v.encoded.should == true
      end
      it "should grab the encoded value from the encoding data if it's locally false" do
        @v.should_receive(:encoding_data).and_return({})
        
        @v.encoded
      end
      it "should set the encoded value to true if the encoding data says it's a success" do
        @v.should_receive(:encoding_data).and_return({'status' => 'success'})
        
        @v.encoded.should == true
      end
      it "should set the encoded value to false if the encoding data says anything except success" do
        @v.should_receive(:encoding_data).and_return({'status' => 'jkljlkjlk'})
        
        @v.encoded.should == false
      end      
    end
    
    describe "encoding status" do
      it "should return 'success' if it's true" do
        @v.attributes[:encoded] = true
        @v.encoding_status.should == 'success'
      end
      it "should get the status from the encoding data if it doesn't have a local encoding status" do
        @v.should_receive(:encoding_data).at_least(1).times.and_return({'status' => 'queued'})
        @v.encoding_status.should == "queued"
      end
    end    
  end
  
  describe "private methods" do
    it "should create an S3 signature" do
      S3::Signature.should_receive(:generate_temporary_url_signature).with(:bucket => "BUCKET",
                                                                           :resource => "file.flv",
                                                                           :secret_access_key => "SAKID",
                                                                           :expires_on => "111")
      
      @v.__send__(:signature)
    end

    it "should get panda encoding data and parse it" do
      Panda.should_receive(:get).with("/videos/PVID/encodings.json").and_return(@json)
      JSON.should_receive(:parse).with(@json).and_return([{:id => "file", :extname => ".flv"}])
      
      @v.__send__(:encoding_data)
    end
    
    it "should not hit panda a second time" do
      Panda.should_receive(:get).with("/videos/PVID/encodings.json").and_return(@json)
      JSON.should_receive(:parse).with(@json).and_return([{:id => "file", :extname => ".flv"}])
      
      @v.__send__(:encoding_data)
      @v.__send__(:encoding_data)
    end
    
    it "should create a resource from panda encoding data" do
      @v.__send__(:resource).should == "file.flv"
    end
    
    it "should set a S3 expiration time of 100 seconds past right now" do
      @v = MyVideo.new
      
      @now = Time.now
      Time.stub!(:now).and_return(@now)
      
      @v.__send__(:s3_expiration).should == @now.strftime("%s").to_i + 100
    end
  end
  
end