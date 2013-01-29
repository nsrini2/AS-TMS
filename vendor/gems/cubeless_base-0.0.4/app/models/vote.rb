# SSJ 2012-8-15 To add voting cabailites to other models
# add the following migration to that models table:
#
# add_column :TABLE_NAME, :num_positive_votes, :integer, :null => false, :default => 0
# add_column :TABLE_NAME, :num_negative_votes, :integer, :null => false, :default => 0
# add_column :TABLE_NAME, :net_helpful, :integer, :null => false, :default => 0
# add_index :TABLE_NAME, :net_helpful
#
# then render the voting partial where you want to place votes
# <%= render :partial 'votes/show', :locals => { :owner => INSTANCE_TO_VOTE_ON } %>


class Vote < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  belongs_to :profile

  def self.current_user_voted_positive(owner)
    owner.votes.where(:profile_id => current_profile.id).where(:vote_value => true).count > 0
  end

  def self.current_user_voted_negative(owner)
    owner.votes.where(:profile_id => current_profile.id).where(:vote_value => false).count > 0
  end

  def self.current_user_has_voted?(owner)
    current_user_voted_positive(owner) || current_user_voted_negative(owner)
  end

protected

  def self.current_profile
    current_profile = AuthenticatedSystem.current_profile
  end

  def owner_const
    Kernel.const_get(owner_type)
  end
  
  def voted_positive?
    self.vote_value
  end

  def before_create
    #!H update the counter cache values for any observers
    if voted_positive?
      owner.num_positive_votes += 1
    else
      owner.num_negative_votes += 1
    end
  end
  
  def after_create
    if voted_positive?
      owner_const.update_all("num_positive_votes=num_positive_votes+1, net_helpful=net_helpful+1","id=#{owner_id}")
    else
      owner_const.update_all("num_negative_votes=num_negative_votes+1, net_helpful=net_helpful-1","id=#{owner_id}")
    end
  end
  
  def after_destroy
    if voted_positive?
      owner_const.update_all("num_positive_votes=num_positive_votes-1, net_helpful=net_helpful-1","id=#{owner_id}")
    else
      owner_const.update_all("num_negative_votes=num_negative_votes-1, net_helpful=net_helpful+1","id=#{owner_id}")
    end
  end

end
