require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe News do
  before(:each) do
    @blog = Factory.build(:blog);
    @blog_posts = Factory.build(:blog_post)
    News.instance.stub!(:blog).and_return(@blog)
    News.instance.stub!(:blog_posts).and_return(@blog_posts)     
  end
  
  it "should return the instance of News with News.find(*args)" do
    assert_equal(News.find(1231), News.instance, "News.find failed to return the singleton instance of News")
  end
  
  it "should pass all unhandled class method calls to the instance" do
    news = News.instance
    test_methods = [:blog, :blog_posts, :private?]
    test_methods.each do |method|
      news.should_receive(method)
      News.send method
    end
  end
  
  it "any unhandled class method calls not responded to by the instance should be passed to super" do
    news = News.instance
    test_methods = [:sample, :not_me, :error]
    test_methods.each do |method|
      Object.should_receive(:method_missing).with(method, 'arg1', 'arg2')
      News.send method, 'arg1', 'arg2'
    end
  end
  
end
