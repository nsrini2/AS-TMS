
  profiles.each do |profile|
    xml << render(:partial => "profile_index", :locals => {:profile => profile})
  end
  groups.each do |group|
    xml << render(:partial => "group_index", :locals => {:group => group})
  end 
  blog_posts.each do |blog_post|
    xml << render(:partial => "blog_post_index", :locals => {:blog_post => blog_post})
  end
  questions.each do |question|
    xml << render(:partial => "question_index", :locals => {:question => question})
  end
  chats.each do |chat|
    xml << render(:partial => "chat_index", :locals => {:chat=> chat})
  end