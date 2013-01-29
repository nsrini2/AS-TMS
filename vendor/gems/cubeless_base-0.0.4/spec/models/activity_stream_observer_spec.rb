require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActivityStreamObserver do
  describe "creating" do
    before(:each) do
      @user = mock_model(User, :email => "iwantemail@bla.com")
      @profile = mock_model(Profile,
        :user => @user,
        :email => @user.email,
        :active? => true,
        :last_login_date => nil)
      @user.stub!(:profile => @profile)

      @observer = ActivityStreamObserver.instance
    end

    describe "status" do
      before(:each) do
        @model = mock_model(Status, :profile_id => 1)
      end
      
      it "should add it to the stream" do
        ActivityStreamEvent.should_receive(:add).with(Status, @model.id, :create, { :profile_id => 1 })
        
        @observer.after_create(@model)
      end
    end
  end


  describe "deleting" do
    before(:each) do
      @observer = ActivityStreamObserver.instance
    end

    describe "status" do
      before(:each) do
        @model = mock_model(Status, :profile_id => 1)
      end
      
      it "should remove it from the stream" do
        ActivityStreamEvent.should_receive(:delete_all).with("klass='Status' and klass_id=#{@model.id}")
        
        @observer.before_destroy(@model)
      end
    end
  end
end

