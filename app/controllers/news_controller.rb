class NewsController < ApplicationController
  
  def index
    begin
      @news = Group.find(83).blog.blog_posts.recent
    rescue
      @news = []
    end
  end
  
end