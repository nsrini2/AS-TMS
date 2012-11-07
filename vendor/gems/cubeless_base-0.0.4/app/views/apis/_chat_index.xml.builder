xml.document do
  xml.type('chat')
  xml.id("chat_#{chat.id}")
  xml.title(chat.title)
  xml.topics do 
    chat.topics.each do |topic|
      xml.topic do 
        xml.title(topic.title)
        xml.posts do
          topic.posts.each do |post|
            xml.text(post.body)
          end
        end
      end
    end
  end
  xml.security do
    xml.groupid("")
  end
end