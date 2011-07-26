class CompanyStreamObserver < ActiveRecord::Observer

  observe Question, Answer #, Profile, ProfilePhoto, Group, GroupPhoto, BlogPost, Comment, GroupMembership, ProfileAward, Status

  @@monitor_create = [Question, Answer].to_set
  def after_create(model)    
    return unless @@monitor_create.member?(model.class)
    return if skip_logging?(model)
    opts = {:profile_id => model.profile_id }
    CompanyStreamEvent.add(model.class,model.id,:create, model.company_id, opts) unless opts.empty?
  end


private
  def skip_logging?(model)
    !model.company?
  end

end