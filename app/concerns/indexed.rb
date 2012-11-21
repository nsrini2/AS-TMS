# to update index:
# rake environment tire:import CLASS=Article FORCE=true
module Indexed
  module Profile
    def self.included(base)
      base.mapping do
        #first is name in index, as => name of attribute or method
        base.indexes :screen_name,     :as => 'screen_name',      :analyzer => 'snowball',  :boost => 10
        base.indexes :search_content,  :as => 'search_content',   :analyzer => 'snowball',    :boost => 5
      end
    end
  end
  
  module Group
    def self.included(base)
      base.mapping do
        base.indexes  :private,          :as => 'private?',          :index => 'not_analyzed',   :type => 'boolean'
        base.indexes  :description,      :as => 'description',       :analyzer => 'snowball',    :boost => 5
        base.indexes  :search_content,   :as => 'search_content',    :analyzer => 'snowball',    :boost => 0
      end
    end
  end
  
  module BlogPost
    def self.included(base)
      base.mapping do
        base.indexes  :private,          :as => 'private?',          :index => 'not_analyzed',   :type => 'boolean'
        base.indexes  :company,          :as => 'company?',          :index => 'not_analyzed',   :type => 'boolean'
        base.indexes  :title,            :as => 'title',             :analyzer => 'snowball',    :boost => 5
        base.indexes  :tags,             :as => 'tags_text',         :analyzer => 'snowball',    :boost => 5
        base.indexes  :text,             :as => 'text',              :analyzer => 'snowball',    :boost => 0
        base.indexes  :comments,         :as => 'comments_text',     :analyzer => 'snowball',    :boost => 0
      end
    end
  end
  
  module Question
    def self.included(base)
      base.mapping do
        base.indexes  :private,          :as => 'private?',          :index => 'not_analyzed',   :type => 'boolean'
        base.indexes  :company,          :as => 'company?',          :index => 'not_analyzed',   :type => 'boolean'
        base.indexes  :question,         :as => 'question',          :analyzer => 'snowball',    :boost => 10
        base.indexes  :answers,          :as => 'answers_text',      :analyzer => 'snowball',    :boost => 5
      end
    end
  end
  
  module Chat
    def self.included(base)
      base.mapping do
        base.indexes :title,           :as => 'title',         :analyzer => 'snowball',    :boost => 10
        base.indexes :topics,          :as => 'topics_text',   :analyzer => 'snowball',    :boost => 5
        base.indexes :posts,           :as => 'posts_text',    :analyzer => 'snowball',    :boost => 0
      end
    end
  end
end
