require_cubeless_engine_file :model, :question

class Question
  # SSJ -- it would be cool to do this with a lamda for curent_profile.company_id, but I could not get it to work
  default_scope :conditions => ["questions.company_id = 0"]
  belongs_to :company
  has_many  :answers
  
  def company?
    self.company_question?
  end
  
  def company_question?
    self.company_id != 0
  end
  
class << self
  ### Summary Methods ###

  def find_summary(*args)
    unscoped = args[1].delete(:unscoped) if args[1]
    ModelUtil.get_options!(args).delete(:summary)
    ModelUtil.add_includes!(args,{:profile => [:user,:primary_photo]}, :abuse)
    ModelUtil.add_selects!(args,"questions.*, (select count(distinct qr.owner_id) from question_referrals qr where qr.question_id=questions.id and qr.owner_type='Group') as num_group_referrals")
    current_profile = AuthenticatedSystem.current_profile
    ModelUtil.add_selects!(args,"(select count(1) from bookmarks where question_id=questions.id and profile_id=#{current_profile.id} limit 1) as being_watched") if current_profile
    referral_owner = ModelUtil.get_options!(args).delete(:referral_owner)
    ModelUtil.add_selects!(args,"(select count(1) from question_referrals qr join profiles p_referer on qr.referer_id=p_referer.id where p_referer.status>0 and p_referer.visible=1 and questions.id=qr.question_id and qr.owner_id=#{referral_owner.id} and qr.owner_type='Profile') as num_referred_to_me, (select count(1) from question_referrals qr join profiles p_target on qr.referer_id=p_target.id where p_target.status>0 and p_target.visible=1 and questions.id=qr.question_id and qr.active = 1 and qr.referer_id=#{referral_owner.id}) as num_i_referred") if referral_owner
    if unscoped
      self.with_exclusive_scope { find(*args ) }
    else
      find(*args)
    end  
  end
  
  def unscoped(which = :all, *opts)
    self.with_exclusive_scope { find(which, opts) } 
  end
  
  def company_questions(company_id, opts={})
    opts[:page][:unscoped] = true if opts[:page]
    ModelUtil.add_conditions!(opts, ["questions.company_id = ?", company_id] )
    here "A"
    here opts.inspect
    self.with_exclusive_scope { find(:all, opts ) }
  end
  
  def community_and_company_questions(company_id)
    self.with_exclusive_scope { find(:all, :conditions => ["questions.company_id = 0 OR questions.company_id = ?", company_id]) }
  end
end  
end