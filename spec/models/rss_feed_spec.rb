require 'spec_helper'

describe RssFeed do
  before(:each) do
    @rss = Factory.build(:rss_feed);
    @rss.stub!(:profile_id).and_return(1)
    @rss.stub!(:blog_id).and_return(1)
    @rss.stub!(:tagline).and_return('stubbed rss_feed tagline')
  end
  
  it "should fetch and add blogposts with rss_feed profile_id, blog_id and tagline" do
    feed1 = Feedzirra::Parser::RSSEntry.new()
              feed1.entry_id   = "full_url"
              feed1.title      = "title"
              feed1.summary    = "summary"
              feed1.published  =  nil
              feed1.source     = "source"
              feed1.url        = "external_link"
              feed1.categories = "tags/categories"                                        
    feeds = [feed1]
    Feedzirra::Feed.stub!(:fetch_and_parse).and_return(feeds)
    create_post = { :tag_list=>"tags/categories", 
                    :created_at=> nil, 
                    :profile_id=>1, 
                    :text=>"summary", 
                    :link=>"external_link", 
                    :guid=>"full_url", 
                    :blog_id=>1, 
                    :source=>"source", 
                    :title=>"title", 
                    :tagline=>"stubbed rss_feed tagline"}
    BlogPost.should_receive(:create).with(create_post).and_return(true)
    @rss.add_blog_posts
    
  end  
end
