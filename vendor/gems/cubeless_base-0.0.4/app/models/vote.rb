class Vote < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true
  belongs_to :profile

  protected
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
