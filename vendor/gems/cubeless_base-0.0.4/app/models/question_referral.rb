class QuestionReferral < ActiveRecord::Base
  include GroupOwned

  belongs_to :owner, :polymorphic => true
  belongs_to :referer, :class_name => 'Profile', :foreign_key => 'referer_id'
  belongs_to :question
  belongs_to :profile, :foreign_key => 'owner_id'
  belongs_to :group, :foreign_key => 'owner_id'

  stream_to :activity

  def self.clear_all_by_question_id_and_owner(question_id, owner)
    update_all "active=0","question_id=#{question_id} and owner_id=#{owner.id} and owner_type='#{owner.class.name}'"
  end

  def self.remove_closed
    ActiveRecord::Base.connection.update("update question_referrals qr join questions q on qr.question_id = q.id set active = 0 where q.open_until <= CURDATE() and qr.active = 1")
  end

  def validate
    cant_find_match_error = "Hum? We can't seem to find a match.  You might try an alternate spelling or word order. "
    refer_to_author_error = "Now, now #{referer.first_name}, you can't refer a question to its author. Try sending it to someone else."
    already_referred_error = "You already referred this question to #{owner.full_name}.  Try sending it to another." if owner
    errors.add_to_base(cant_find_match_error) unless owner
    errors.add_to_base(refer_to_author_error) if question.profile == owner
    errors.add_to_base(already_referred_error) if already_referred
    errors.add_to_base("Sorry, #{owner.full_name} is a Sponsored Member and may not be referred a question.") if owner && owner.is_a?(Profile) && owner.is_sponsored?
  end

  def already_referred
    referer.questions_i_referred.find(:first, :conditions => ["question_id = ? and question_referrals.owner_id = ? and question_referrals.owner_type = ?", question_id, owner_id, owner_type])
  end

  def authored_by?(profile)
    profile && (self.referer == profile)
  end

  def referred_to_name
    self.owner.is_a?(Group) ? self.owner.name : self.owner.screen_name
  end
  
  def send_group_question_referral
    recipients = get_group_recipients(self.owner.group_memberships)
    BatchMailer.mail(self, recipients) unless recipients.blank?
  end

end
