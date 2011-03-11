require_cubeless_engine_file :helper, :groups_helper

module GroupsHelper
  
  def group_active_qa_count(group)
    unless group.active_questions_referred_to_me.empty?
      "(<span class='inline' id='matchedq'>#{group.active_questions_referred_to_me.count}</span>)"
    end  
  end
  
  
end