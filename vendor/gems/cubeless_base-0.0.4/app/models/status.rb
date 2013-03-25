class Status < ActiveRecord::Base

  belongs_to :profile

  stream_to :activity

  # MM2: Apparently only in Rails 2.3 :(
  # default_scope :order => 'created_at DESC'
  
  named_scope :by_profile, lambda { |profile| { :conditions => ["profile_id = ?", profile.id], :order => "created_at DESC", :limit => 10 } }

  named_scope :recent, :order => "created_at DESC", :limit => 10   
  named_scope :most_recent, :order => "created_at DESC", :limit => 3 

  def after_save
    SemanticMatcher.default.status_updated(self)
  end
  def after_destroy
    SemanticMatcher.default.status_deleted(self)
  end

  class << self
    def find_by_keywords(query, options)
      SemanticMatcher.default.search_statuses(query, options.merge!({:direct_query => true}))
    end
  
    def find_duplicates
      duplicates = ActiveSupport::OrderedHash.new
    
      # SSJ - I tried doing this with ActiveRecord, but the having clause got repeated twice, so I reverted to find_by_sql
      # Status.find(:all, :select => "*, count(id) as my_count, GROUP_CONCAT(id) as duplicates", :group => " body, profile_id ", :having => "my_count > 1" )
      dups = Status.find_by_sql("SELECT id, count(id) as my_count, GROUP_CONCAT(id) as duplicate_ids 
                                  FROM statuses
                                  GROUP BY body, profile_id
                                  HAVING my_count > 1")
      # SSJ loop though all groups of duplicate entries
      dups.each do |dup|
        # SSJ loop through each group and get each status that is duplicated
        duplicate_statuses = []
        dup.duplicate_ids.split(",").each do |id|
          duplicate_statuses << Status.find(id)
        end
        # SSJ add array of duplicate status to hash
        duplicates["#{(duplicates.size + 1)}"] = duplicate_statuses
      end
    
      duplicates
    end
  
  
    def destroy_duplicates
      # SSJ keep first duplicate entry and destroy the rest
      duplicates  = find_duplicates
      total = 0
      duplicates.each_pair do |key, dups|
        keep = dups.delete_at(0) # remove fist Status from array
        dups.each do |status| 
          puts "Deleting Status => #{status.inspect}"
          status.destroy
          total += 1
        end  
      end
      
      "Deleted #{total} Status(es)."  
    end
  
  end  
end
