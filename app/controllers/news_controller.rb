class NewsController < ApplicationController
  
  def index
    begin
      @news = Group.find(16).blog.blog_posts.recent
    rescue
      @news = []
    end
  end
  
end