require_cubeless_engine_file :model, :question_referral

class QuestionReferral < ActiveRecord::Base
  include Notifications::QuestionReferral

  def validate
    cant_find_match_error = "Hum? We can't seem to find a match.  You might try an alternate spelling or word order. "
    refer_to_author_error = "Now, now #{referer.first_name}, you can't refer a question to its author. Try sending it to someone else."
    already_referred_error = "You already referred this question to #{owner.full_name}.  Try sending it to another." if owner
    company_to_company_error = "You can only refer company questions to another member of the same company or agency."
    errors.add_to_base(cant_find_match_error) unless owner
    errors.add_to_base(refer_to_author_error) if question.profile == owner
    errors.add_to_base(already_referred_error) if already_referred
    errors.add_to_base(company_to_company_error) unless company_to_company
    errors.add_to_base("Sorry, #{owner.full_name} is a Sponsored Member and may not be referred a question.") if owner && owner.is_a?(Profile) && owner.is_sponsored?
  end

  def company_to_company
    return true unless self.question.company_question?
    return true if self.question.company == owner.company
    false  
  end

end