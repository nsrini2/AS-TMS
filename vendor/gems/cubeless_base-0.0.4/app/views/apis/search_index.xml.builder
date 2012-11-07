xml.contentfeed do
  xml.new do
    xml << render(:partial => "type_index", :locals => {:profiles => @new_profiles, 
                                                        :groups => @new_groups, 
                                                        :blog_posts => @new_blog_posts,
                                                        :questions => @new_questions,
                                                        :chats => @new_chats })
  end
  xml.updated do
    xml << render(:partial => "type_index", :locals => {:profiles => @update_profiles, 
                                                        :groups => @update_groups, 
                                                        :blog_posts => @update_blog_posts,
                                                        :questions => @update_questions,
                                                        :chats => @update_chats })
  end
  xml.deleted do
    xml << render(:partial => "type_index", :locals => {:profiles => @delete_profiles, 
                                                        :groups => @delete_groups, 
                                                        :blog_posts => @delete_blog_posts,
                                                        :questions => @delete_questions,
                                                        :chats => @delete_chats })
  end
end