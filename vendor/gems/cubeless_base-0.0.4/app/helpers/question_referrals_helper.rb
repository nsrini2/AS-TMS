module QuestionReferralsHelper

  def referred_to_content_for(questions_for, question, options={})
    render :partial => 'questions/question_referred_to', :locals => {:questions_for => questions_for, :question => question} if(options[:referred_to] and question.num_i_referred > 0)
  end

  def referred_by_content_for(questions_for, question, options={})
    render :partial => 'questions/question_referred_by', :locals => {:questions_for => questions_for, :question => question} if(options[:referred_by] and question.num_referred_to_me > 0)
  end

  def referred_to_link(profile, question)
    profiles = question.referred_to_profiles.visible.find(:all, {:conditions => ['referer_id = ?', profile.id]})
    groups = question.referred_to_groups.find(:all, {:conditions => ['referer_id = ?', profile.id]})
    if question.num_i_referred > 2
      [(link_to(pluralize(profiles.size, "person", "people"), profiles_referred_to_question_explorations_path(:question_id => question.id, :referer_id => profile.id)) if profiles.size > 0),
        (link_to(pluralize(groups.size, "group", "groups"), groups_referred_to_question_explorations_path(:question_id => question.id, :referer_id => profile.id)) if groups.size > 0)].compact.join(' and ')
    else
      (profiles + groups).collect { |profile_result|
        link_to profile_result.full_name, eval("#{profile_result.class.name.downcase}_path(profile_result.id)")
      }.join(' and ')
    end
  end

  def referred_by_link(object, question)
    if question.num_referred_to_me > 2
      link_to(pluralize(question.num_referred_to_me, "person", "people"), question_referrers_explorations_path(:question_id => question.id))
    else
      Profile.visible.find(:all, :joins => "join question_referrals qr on qr.active=1 and profiles.id=qr.referer_id and qr.question_id=#{question.id} and qr.owner_id=#{object.id} and qr.owner_type='#{object.class.name}'").collect { |profile_result|
        link_to profile_result.screen_name, profile_path(profile_result.id)
      }.join(' and ')
    end
  end

  def link_to_refer(question)
    return unless question.is_open?
    link_to('Refer', new_question_referral_path(:question_id => question.id), :class => 'button little light refer')
  end

  def referred_to_groups_content_for(question, options={})
    render :partial => 'questions/question_referred_to_groups', :locals => {:question => question} if(options[:referred_to_groups] and question.num_group_referrals > 0)
  end

  def referred_to_groups_link(question)
    if question.num_group_referrals > 2
      link_to(pluralize(question.num_group_referrals, "group", "groups"), groups_referred_to_question_explorations_path(:question_id => question.id))
    else
      groups = question.referred_to_groups.find(:all, :select => 'DISTINCT question_referrals.owner_id')
      groups.collect { |group|
        link_to group.name, group_path(group.id)
      }.join ' and '
    end
  end

end