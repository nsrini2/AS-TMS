module ProfilesHelper

  def empty_watch_list_content_for(questions)
    content_tag(:div, image_tag("/images/watchList.gif"), :align => "center") if questions.size.zero?
  end

  def render_widget_home_ask_question
    render :partial => 'widgets/ask_question'
  end

  def render_widget_home_explore_profiles
    render :partial => 'widgets/explore_profiles'
  end

  def render_widget_home_status
    render :partial => 'widgets/update_status'
  end

  def render_widget_watch_list(questions)
    render :partial => 'widgets/questions', :locals => {
      :title => "Watch List (#{questions.size})",
      :questions => questions,
      :show => {:avatar => true, :asked_by => true},
      :view_all_url => watched_questions_profile_path(current_profile),
      :empty_widget_message => "You're not stalking any questions right now. You can always find more by #{link_to "exploring questions", questions_explorations_path, :class => 'empty'}"
    }
  end

  def render_widget_home_notes
    render :partial => 'widgets/recent_notes'
  end

  def render_widget_random_terms
    render :partial => 'widgets/hot_topics'
  end

  def render_widget_newest_question
    render :partial => 'widgets/questions', :locals => {
      :title => "Latest Community Question",
      :questions => Question.find_summary(:all, :order => 'questions.created_at DESC', :limit => 1),
      :show => { :avatar => true, :asked_by => true, :full_text => false },
      :view_all_url => questions_explorations_path,
      :empty_widget_message => "No questions have been asked yet."
    }
  end

  def render_widget_questions_with_new_answers(questions)
    render :partial => 'widgets/questions', :locals => {
    :title => "Questions with New Answers (#{questions.size})",
    :questions => questions,
    :show => { :answer_link => true, :full_text => false },
    :view_all_url => questions_asked_profile_path(current_profile),
    :empty_widget_message => "Sorry, no new answers yet. Check back soon."
    }
  end

  def render_widget_referred_questions(questions)
    render :partial => 'widgets/questions', :locals => {
    :title => "Referred Questions (#{questions.size})",
    :questions => questions,
    :show => { :avatar => true, :asked_by => true, :full_text => false },
    :view_all_url => matched_questions_profile_path(current_profile),
    :empty_widget_message => "Hey, no one's referred a question to you! Tell your friends to get on the ball."
    }
  end

  def render_widget_matched_questions(questions)
    render :partial => 'widgets/questions', :locals => {
    :title => "Questions I Can Help Answer (#{questions.size})",
    :questions => questions,
    :show => { :avatar => true, :asked_by => true, :full_text => false },
    :view_all_url => matched_questions_profile_path(current_profile),
    :empty_widget_message => "Surely there must be a question you can help answer. Try one of the #{link_to "unanswered questions", questions_explorations_path(:filter_scope => 'unanswered'), :class => 'empty'}"
    }
  end

  def render_alternate_photos_for(profile, photos)
    alt_photos = photos.collect{ |photo| link_to(image_tag(photo_path_for(profile, photo), :alt => "",  :size => '50x50', :class => 'avatar'), select_profile_photo_path(profile, photo)) }
    if profile==current_profile || current_profile.has_role?(Role::ShadyAdmin)
      unused_slots = 4-photos.size
      (unused_slots-1).downto(0) do |i|
        alt_photos << (@profile.karma.nth_photo_allowed?(5 - i) ? link_for_alternate_photo(@profile) : locked_alternate_photo(Karma.points_required_for_nth_photo(5 - i), profile))
      end
    end
    if alt_photos.empty?
      "&nbsp;"
    else
      alt_photos.to_s
    end
  end

  def link_for_alternate_photo(profile)
    link_to(image_tag(generic_photo_path_for(profile), :id => "photo_empty", :alt => "",  :size => '50x50', :class => 'avatar'), select_profile_photo_path(profile,0))
  end

  def locked_alternate_photo(points, profile)
    image_tag('/images/genAvatarLocked.png', { :alt => "",  :size => '50x50', :class => 'avatar tooltip', :title => "Earn #{points} karma to unlock this photo spot" } )
  end

  def question_sections
    Config[:profile_complex_questions]
  end

  def empty_slots_content(slots)
    yield if slots.zero?
  end

  def available_slots_content(slots)
    yield if slots > 0
  end

  def karma_needed_to_unlock_more_group_slots(profile)
    case profile.karma_points
      when 0..79 : 80
      when 80..199 : 200
      else 400
    end
  end

  def render_empty_slots_content_for(profile, slots)
    (slots.zero? and profile.groups.size < 20) ? "Earn #{karma_needed_to_unlock_more_group_slots(profile)} Karma points to add 5 more" : "You are all maxed out"
  end

end
