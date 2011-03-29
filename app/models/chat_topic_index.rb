require "#{Rails.root}/vendor/plugins/live_qa/app/models/chat_topic_index"
require "#{Rails.root}/vendor/plugins/cubeless/components/semantic_matcher"
require "#{Rails.root}/vendor/plugins/cubeless/components/mysql_semantic_matcher"

class ChatTopicIndex < ActiveRecord::Base

  
  def text_index_prep(text, exclude_terms_set=nil, remove_weak_terms=true)
    #SSJ 2010-02-24 This method is just a hook to allow for easy integreation into Cubeless environments
    matcher = MysqlSemanticMatcher.new
    matcher.prep_text_for_match_query(text, exclude_terms_set, remove_weak_terms)
  end
 
class << self 
  def find_by_keywords(search_text, options={})
    matcher = MysqlSemanticMatcher.new
    options = {:direct_query => false }.merge options
    search_text = matcher.prep_text_for_match_query(search_text, true, !options.delete(:direct_query) )
    # require words with a + dissallow results having a word that is -
    if (search_text.index('+')) ||  (search_text.index('-'))
      mode = "IN BOOLEAN MODE"
    else
      mode = ""
    end    
    mysql_match_term = "MATCH (chat_topic_indices.chat_title_text, chat_topic_indices.topic_text, chat_topic_indices.posts_text) AGAINST (? #{mode})"
    ModelUtil.add_joins!(options, 'join chat_topic_indices on chat_topic_indices.topic_id = topics.id')
    ModelUtil.add_conditions!(options,["#{mysql_match_term}",search_text])
    options = matcher.options_with_rank(options, mysql_match_term, search_text, ["topics.*"])
    Topic.find(:all, options)
  end
 
end 
  
end