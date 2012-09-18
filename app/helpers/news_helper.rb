module NewsHelper
  # SSJ -- not sure I like having a return in the middle of the if statement
  def link_to_follow_news
    label = if NewsFollower.following?(current_profile)
              "UnFollow"
            else
              "Follow"
            end
                 
    link_to(label, news_follow_path, :class => 'follow_news_link button large', :method => :post )
  end

end