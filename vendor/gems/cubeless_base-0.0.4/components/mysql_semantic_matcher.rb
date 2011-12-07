class MysqlSemanticMatcher < SemanticMatcher

  @@mysql_stop_words = SemanticMatcher.load_data_set('mysql_stop_words.txt')
  @@stop_words.merge(@@mysql_stop_words)

  def mysql_stop_words
    @@mysql_stop_words
  end

  ### Question functions ###

  def question_updated(question)
    # do not delete the question text index, can still search it if closed
    qti = QuestionTextIndex.find_or_create_by_question_id(question.id)
    qti.question_text = text_index_text_prep(question.matchable_text)
    qti.save!
    if question.is_open?
      # now called async
      #match_question_to_profiles(question)
    else
      #!I QuestionProfileExcludeMatch  #!? do we want to delete these immediately?
      QuestionProfileMatch.delete_all(['question_id=?',question.id])
    end
  end

#  def close_question(question)
#    QuestionProfileMatch.delete_all(['question_id=?',question.id])
#    #!I QuestionProfileExcludeMatch  #!? do we want to delete these immediately?
#    QuestionTextIndex.delete_all(['question_id=?',question.id])
#  end

  def question_deleted(question)
    QuestionTextIndex.delete_all(['question_id=?',question.id])
    QuestionProfileMatch.delete_all(['question_id=?',question.id])
    QuestionProfileExcludeMatch.delete_all(['question_id=?',question.id])
  end

#  def match_group_to_questions(group)
#
#    return if group.tags.blank?
#
#    tags = group.tags.split(',')
#    tags.each { |tag| tag.strip! }
#    match_terms = tags.collect { |tag| "\"#{tag}\"" }.join(' ')
#
#    mysql_match_query = '(match (qti.question_text) against (? IN BOOLEAN MODE))'
#    ps = db_prepare("select qti.question_id, #{mysql_match_query} as rank from question_text_indices qti"+
#    " left join group_question_matches gqm on gqm.group_id=? and gqm.question_id=qti.question_id"+
#    " where gqm.id is null and #{mysql_match_query}")
#    ps.execute(match_terms,group.id,match_terms)
#
#    while rs = ps.fetch
#      GroupQuestionMatch.new(:group_id => group.id, :question_id => rs[0], :rank => rs[1]).save!
#    end
#    ps.close
#
#  end

#  def match_question_to_groups(question)
#
#    return if !question.is_open?  #!I this should throw an exception
#    query_text = prep_text_for_match_query(question.matchable_text)
#    mysql_match_term = '(match (gti.tags_text) against (?))'
#
#    ps = db_prepare("select gti.group_id, #{mysql_match_term} as rank from group_text_indices gti"+
#    " left join group_question_matches gqm on gqm.group_id=gti.group_id and gqm.question_id=? "+
#    " where gqm.id is null and #{mysql_match_term} having rank>=1")
#    ps.execute(query_text,question.id,query_text)
#
#    while rs = ps.fetch
#      GroupQuestionMatch.new(:group_id => rs[0], :question_id => question.id, :rank => rs[1]).save!
#    end
#    ps.close
#
#  end

  def match_question_to_profiles(question)

    return if !question.is_open?  #!I this should throw an exception

    query_text = prep_text_for_match_query(question.matchable_text)
    mysql_match_term = 'match (pti.profile_text,pti.answers_text) against (?)'
    
    QuestionProfileMatch.transaction do
      
      #QuestionProfileMatch.delete_all(['question_id=?',question.id])

      # calculate the average rank above the base_rank (>=1)
      ps = db_prepare("select avg(#{mysql_match_term}) as avg_rank from profile_text_indices pti"+
      " join profiles p on p.id=pti.profile_id"+
      " left join answers a on a.question_id=? and a.profile_id=pti.profile_id"+
      " where p.status=1 and a.id is null"+
      " and p.roles NOT REGEXP '^(6|8)'"+ # Do not recommend to sponsor members
      " and pti.profile_id!=?"+
      " and (#{mysql_match_term})>=1"+
      " limit ? ")
      ps.execute(query_text,question.id,question.profile_id,query_text,@@question_match_max_prefetch)

      min_rank = ps.fetch[0]
      
      ps.close
      return if min_rank.nil?
      min_rank = 1 if min_rank<1

      # mysql text results are naturally in a descending rank order
      ps = db_prepare("select pti.profile_id, (#{mysql_match_term}) as rank from profile_text_indices pti"+
      " join profiles p on p.id=pti.profile_id"+
      " left join question_profile_exclude_matches qpim on qpim.profile_id=pti.profile_id and qpim.question_id=?"+
      " left join answers a on a.question_id=? and a.profile_id=pti.profile_id"+
      " where p.status=1 and qpim.id is null and a.id is null"+
      " and pti.profile_id!=?"+
      " and #{mysql_match_term}"+
      " having rank>=? limit ? ")
      ps.execute(query_text,question.id,question.id,question.profile_id,query_text,min_rank,@@question_match_max_prefetch)

      insert = 'insert into question_profile_matches (question_id,profile_id,rank,`order`) values '
      rownum = 1
      while rs = ps.fetch
        QuestionProfileMatch.find_or_create_by_question_id_and_profile_id(:question_id => question.id,:profile_id => rs[0],:rank => rs[1], :order => rownum)
        rownum += 1
      end
      ps.close

    end

  end

  def search_questions(questions_model,search_text,options={})
    options[:direct_query] ||= false
    search_text = prep_text_for_match_query(search_text,true,!options.delete(:direct_query))

    # binary mode allows us to search quoted phrases, and specify + or - qualifiers
    #!H boolean mode switch, this is currently used in ask a ?, and didnt want to force boolean if not needed (dont know repercussions)
    if (search_text.index('"'))
      mysql_match_term = 'match (qti.question_text) against (? IN BOOLEAN MODE)'
    else
      mysql_match_term = 'match (qti.question_text) against (?)'
    end

    ModelUtil.add_joins!(options,'join question_text_indices qti on qti.question_id=questions.id')
    
    # MM2: Allow closed questions to be searched
    # ModelUtil.add_conditions!(options,["#{mysql_match_term} and (current_date()<questions.open_until or exists (select 1 from answers where question_id=questions.id limit 1))",search_text])
    ModelUtil.add_conditions!(options,["#{mysql_match_term}",search_text])
    
    # MM2: This allows the rank to come through with the results. The search should be sanitized and therefore ok to use like this
    options = options_with_rank(options, mysql_match_term, search_text, ["questions.*"])
    
    questions_model.find(:all, options)
    #Question.find_by_sql(["select questions.*, #{Question.vselect_num_answers} from questions, question_text_indices qti where questions.id=qti.question_id and match (qti.question_text) against (?) limit ?",search_text,limit])
  end

  def search_profiles(search_text,options={})
    options[:direct_query] ||= false
    search_text = prep_text_for_match_query(search_text, true, !options.delete(:direct_query))
    if (search_text.index('"'))
      mysql_match_term = 'match (pti.profile_text, pti.answers_text) against (? IN BOOLEAN MODE)'
    else
      mysql_match_term = 'match (pti.profile_text, pti.answers_text) against (?)'
    end
    options[:status] = :visible
    ModelUtil.add_joins!(options,'join profile_text_indices pti on pti.profile_id=profiles.id')
    ModelUtil.add_conditions!(options,["#{mysql_match_term}",search_text])
    
    # MM2: This allows the rank to come through with the results. The search should be sanitized and therefore ok to use like this
    options = options_with_rank(options, mysql_match_term, search_text, ["profiles.*"])
    
    Profile.find(:all, options)
  end

#  def split_terms_quoted(s)
#    terms = []
#    qsplits = s.split('"')
#    qsplits.each_index do |i|
#      qsplit = qsplits[i]
#      # each odd item is in quotes
#      if i%2==1
#        qsplit.strip!
#        terms << qsplit
#      else
#        qsplit.split(' ').each do |word|
#          word.strip!
#          terms << word unless word.length==0
#        end
#      end
#    end
#    terms
#  end

  def search_groups(search_text,options={})
    options = {:direct_query => false }.merge options
    search_text = prep_text_for_match_query(search_text,true,!options.delete(:direct_query))

    if (search_text.index('"'))
      mysql_match_term = 'match (gti.name_text, gti.description_text, gti.tags_text) against (? IN BOOLEAN MODE)'
    else
      mysql_match_term = 'match (gti.name_text, gti.description_text, gti.tags_text) against (?)'
    end
    ModelUtil.add_joins!(options,'join group_text_indices gti on gti.group_id=groups.id')
    ModelUtil.add_conditions!(options,["#{mysql_match_term}",search_text])
    
    # MM2: This allows the rank to come through with the results. The search should be sanitized and therefore ok to use like this
    options = options_with_rank(options, mysql_match_term, search_text, ["groups.*"])
    
    Group.find(:all, options)
  end

  def search_blog_posts(search_text,options={})
    options = {:direct_query => false }.merge options
    search_text = prep_text_for_match_query(search_text,true,!options.delete(:direct_query))

    if (search_text.index('"'))
      mysql_match_term = 'match (bpti.title_text, bpti.text_text, bpti.cached_tag_list_text, bpti.author) against (? IN BOOLEAN MODE)'
    else
      mysql_match_term = 'match (bpti.title_text, bpti.text_text, bpti.cached_tag_list_text, bpti.author) against (?)'
    end
    ModelUtil.add_joins!(options,'join blog_post_text_indices bpti on bpti.blog_post_id=blog_posts.id')
    ModelUtil.add_conditions!(options,["#{mysql_match_term}",search_text])
    
    # MM2: This allows the rank to come through with the results. The search should be sanitized and therefore ok to use like this
    options = options_with_rank(options, mysql_match_term, search_text, ["blog_posts.*"])
    
    BlogPost.find(:all, options)
  end
  
  def search_getthere_bookings(search_text, options={})
    options = { :direct_query => false }.merge options
    search_text = prep_text_for_match_query(search_text,false,!options.delete(:direct_query))
        
    # TODO: Fix this really janky way of getting and removing scopes
    unless (search_text.index('""'))
      # search_text = "%#{search_text}%"
      
      conditions = options[:conditions]      
      conditions_string = conditions.is_a?(String)
      
      mysql_match_term = ""
      
      if (match = conditions_string && match = conditions.match("getthere_bookings.start_location IS NOT NULL")) || 
              match = conditions.first.match("getthere_bookings.start_location IS NOT NULL")
        # ModelUtil.add_conditions!(options, ["getthere_bookings.start_location LIKE ? OR getthere_bookings.start_airport_code LIKE ?",search_text,search_text])

        mysql_match_term = 'match (gbti.start_location_text, gbti.start_airport_code_text) against (?)'

      elsif (match = conditions_string && match = conditions.match("getthere_bookings.locations IS NOT NULL")) || 
              match = conditions.first.match("getthere_bookings.locations IS NOT NULL")
        # ModelUtil.add_conditions!(options, ["getthere_bookings.locations LIKE ? OR getthere_bookings.destination_airport_codes LIKE ?",search_text,search_text])        

        mysql_match_term = 'match (gbti.locations_text, gbti.destination_airport_codes_text) against (?)'        

      else
        # mysql_match_term = "getthere_bookings.locations LIKE ? OR getthere_bookings.destination_airport_codes LIKE ? OR getthere_bookings.start_location LIKE ? OR getthere_bookings.start_airport_code LIKE ?"
        # ModelUtil.add_conditions!(options, ["#{mysql_match_term}",search_text,search_text,search_text,search_text])
    
        mysql_match_term = 'match (gbti.start_location_text, gbti.locations_text, gbti.start_airport_code_text, gbti.destination_airport_codes_text) against (?)'        
      end
      
      ModelUtil.add_joins!(options,'join getthere_booking_text_indices gbti on gbti.getthere_booking_id=getthere_bookings.id')
      ModelUtil.add_conditions!(options,["#{mysql_match_term}",search_text])
    end
    GetthereBooking.find(:all, options)
  end
  
  
  def search_statuses(search_text,options={})    
    options = {:direct_query => false }.merge options
    
    search_text = prep_text_for_match_query(search_text,true,!options.delete(:direct_query))    
    # search_text = "%#{search_text}%"
    
    # Determine between authors and text
    conditions = options.delete(:conditions).first if options[:conditions]

    if conditions == "author"      
      if (search_text.index('"'))
        mysql_match_term = 'match (sti.author_text) against (? IN BOOLEAN MODE)'
      else
        mysql_match_term = 'match (sti.author_text) against (?)'
      end
      ModelUtil.add_joins!(options,'join status_text_indices sti on sti.status_id=statuses.id')
      ModelUtil.add_conditions!(options,["#{mysql_match_term}",search_text])          
    else      
      if (search_text.index('"'))
        mysql_match_term = 'match (sti.body_text) against (? IN BOOLEAN MODE)'
      else
        mysql_match_term = 'match (sti.body_text) against (?)'
      end
      ModelUtil.add_joins!(options,'join status_text_indices sti on sti.status_id=statuses.id')
      ModelUtil.add_conditions!(options,["#{mysql_match_term}",search_text])
    end
    
    # MM2: This allows the rank to come through with the results. The search should be sanitized and therefore ok to use like this
    options = options_with_rank(options, mysql_match_term, search_text, ["statuses.*"])

    Status.find(:all, options)
  end

  def question_profile_match_deleted(question_profile_match)

      # if count() of question matches drops below threshold, rematch
      ps = db_prepare("select count(1) from question_profile_matches where question_id=?")
      ps.execute(question_profile_match.question_id)
      count = ps.fetch[0]
      ps.close

      #!O eventually mark there were <max_queued found - i.e. never search again
      if count<@@question_match_max_assigned
        # now called async
        #match_question_to_profiles(Question.find(question_profile_match.question_id))
      else
        # shift order #'s of remaining matches
        ps = db_prepare("update question_profile_matches qpm set qpm.order=qpm.order-1 where qpm.question_id=? and qpm.order>?")
        ps.execute(question_profile_match.question_id,question_profile_match.order)
        ps.close
      end

  end

  def get_profile_matched_questions(questions_model, profile, options={})
    questions_model.find(:all, options.merge!(:order => 'rank desc', :select => 'qpm.rank as match_rank', :joins => 'join question_profile_matches qpm on qpm.question_id=questions.id', :conditions => ['questions.open_until>current_date() and qpm.profile_id=? and qpm.order<=?',profile.id,@@question_match_max_assigned]))
  end

  ### Profile functions ###

  def find_questions_relevant_to_profile(questions_model,profile,options={})
    pti = ProfileTextIndex.find_or_create_by_profile_id(profile.id)
    questions_model.find(:all, options.merge!(:joins => "join question_text_indices qti on questions.id=qti.question_id left join question_profile_exclude_matches qpem on questions.id=qpem.question_id and qpem.profile_id=#{profile.id} left join answers a on a.question_id=questions.id and a.profile_id=#{profile.id} left join question_referrals qr on qr.question_id=questions.id and qr.owner_id=#{profile.id} and qr.owner_type='Profile'", :conditions => ['a.question_id is null and qpem.question_id is null and qr.question_id is null and questions.open_until>current_date() and questions.profile_id!=? and match (qti.question_text) against (?)',profile.id,"#{pti.profile_text} #{pti.all_answers_text}"]))
  end

  def find_more_questions_to_answer(questions_model,profile,options={})
  # get more questions after action has been taken on all questions relevant to profiles
    questions_model.find(:all, options.merge!(:joins => "join question_text_indices qti on questions.id=qti.question_id left join question_profile_exclude_matches qpem on questions.id=qpem.question_id and qpem.profile_id=#{profile.id} left join answers a on a.question_id=questions.id and a.profile_id=#{profile.id} left join question_referrals qr on qr.question_id=questions.id and qr.owner_id=#{profile.id} and qr.owner_type='Profile'", :conditions => ['a.question_id is null and qpem.question_id is null and qr.question_id is null and questions.open_until>current_date() and questions.profile_id!=?',profile.id]))
  end

  def filter_questions_relevant_to_profile(profile,options={})
    pti = ProfileTextIndex.find_or_create_by_profile_id(profile.id)
    match_text = "#{pti.profile_text} #{pti.answers_text}"
    ModelUtil.add_joins!(options,"join question_text_indices fqr_qti on questions.id=fqr_qti.question_id")
    ModelUtil.add_conditions!(options,['match (fqr_qti.question_text) against (?)',match_text])
    options[:order] = 'rank desc';
  end

  def profile_updated(profile,reindex_answers=false)

    pti = ProfileTextIndex.find_or_create_by_profile_id(profile.id)
    exclude_terms_set = profile.exclude_terms_set
    pti.profile_text = text_index_text_prep(profile.matchable_text(),exclude_terms_set)
    if reindex_answers #!I #!O only if exclude_terms updated, rebuild all answers
      pti.answers_text = ''
      #!O .find loads all records into memory
      Answer.find(:all, :conditions => ['profile_id=?',profile.id]).each do |answer|
        pti.add_answer(answer.id,text_index_text_prep(answer.matchable_text,exclude_terms_set))
      end
    end
    pti.save!
    rematch_for_profile_text_index(pti)
  end

  def profile_deleted(profile) # @implementation, we dont delete profiles
    ProfileTextIndex.delete_all(['profile_id=?',profile.id])
    QuestionProfileMatch.delete_all(['profile_id=?',profile.id]) #!O destroy?
  end

  def get_profile_keyterms_set(profile)

    pti = ProfileTextIndex.find_or_create_by_profile_id(profile.id)
    text = ''
    text << pti.profile_text if pti.profile_text
    text << pti.all_answers_text

    result = get_terms_set(text,true) # true = already formatted since pti text
    result.subtract(suppress_display_terms)
    result.delete('??') # pti ignored words are stubbed to '??' at present, remove #!H
    result
  end

  ### Blog functions ###

  def blog_post_updated(blog_post)
    bpti = BlogPostTextIndex.find_or_create_by_blog_post_id(blog_post.id)
    bpti.title_text = text_index_text_prep(blog_post.title)
    bpti.text_text = text_index_text_prep(blog_post.text)
    bpti.cached_tag_list_text = text_index_text_prep(blog_post.cached_tag_list)
    bpti.author = text_index_text_prep(blog_post.profile.full_name) + text_index_text_prep(blog_post.profile.screen_name)
    bpti.save!
  end

  def blog_post_deleted(blog_post)
    BlogPostTextIndex.delete_all(['blog_post_id=?',blog_post.id])
  end

  ### Group functions ###

  def group_updated(group)
    gti = GroupTextIndex.find_or_create_by_group_id(group.id)
    gti.name_text = text_index_text_prep(group.name)
    gti.description_text = text_index_text_prep(group.description)
    gti.tags_text = text_index_text_prep(group.tags)
    gti.save!
  end
  
  def group_deleted(group)
    GroupTextIndex.delete_all(['group_id=?',group.id])
  end

  ### Answer functions ###
  def answer_updated(answer)
    pti = ProfileTextIndex.find_or_create_by_profile_id(answer.profile_id)
    pti.remove_answer(answer.id)
    pti.add_answer(answer.id,text_index_text_prep(answer.matchable_text,answer.profile.exclude_terms_set))
    pti.save!
    # remove any existing match and ignore further matching for this profile
    qpm = QuestionProfileMatch.find_by_question_id_and_profile_id(answer.question_id,answer.profile_id)
    qpm.destroy() if qpm
    rematch_for_profile_text_index(pti)
  end

  def answer_deleted(answer)
    pti = ProfileTextIndex.find_or_create_by_profile_id(answer.profile_id)
    pti.remove_answer(answer.id)
    pti.save!
    rematch_for_profile_text_index(pti)
  end

  ### GetthereBooking functions ###
  def getthere_booking_updated(getthere_booking)    
    gbti = GetthereBookingTextIndex.find_or_create_by_getthere_booking_id(getthere_booking.id)
    gbti.start_location_text = text_index_text_prep(getthere_booking.start_location)
    gbti.locations_text = text_index_text_prep(getthere_booking.locations)
    gbti.start_airport_code_text = text_index_text_prep(getthere_booking.start_airport_code)
    gbti.destination_airport_codes_text = text_index_text_prep(getthere_booking.destination_airport_codes)
    gbti.save!
  end

  def getthere_booking_deleted(getthere_booking)
    GetthereBookingTextIndex.delete_all(['getthere_booking_id=?',getthere_booking.id])
  end
  
  ### Status functions ###
  def status_updated(status)    
    sti = StatusTextIndex.find_or_create_by_status_id(status.id)
    sti.body_text = text_index_text_prep(status.body)
    sti.author_text = text_index_text_prep([status.profile.screen_name, status.profile.first_name, status.profile.last_name].compact.join(" "))
    sti.save!
  end

  def status_deleted(status)
    StatusTextIndex.delete_all(['status_id=?',status.id])
  end


  # prepare text before using in a mysql match
  def prep_text_for_match_query(text,exclude_dblquote=false,remove_weak_terms=true)
    result = text.dup
    result.downcase! # downcase for stop_words removal
    result.gsub!("'s",'')
    remove_punctuation_proper!(result,exclude_dblquote)
    result.gsub!(/([^\s]+)/) { |word|
      weak_term?(word) ? '' : word
    } if remove_weak_terms
    result
    #!? check terms as adverbs?
  end

  def text_index_text_prep(text,exclude_terms_set=nil)
    result = " #{text} " # create a new copy, and add spaces as needed by exclude_terms_set gsub
    # these are not really needed for mysql, but for exclude replacements (at present) - could use regex replacement [consider injection risks]
    result.downcase!
    
    # MM2: Remove http:// type terms
    result.gsub!(/http:\/\/\S*/,"")
    
    result.gsub!(/<\/?[^>]*>/, "")
    result.gsub!("'s",'')
    remove_punctuation_proper!(result)
    
    exclude_terms_set.each do |word|
      result.gsub!(" #{word} ",' ?? ') #!H ?? #!O larger length terms need to be processed first
    end if exclude_terms_set
    result
  end
  
  # MM2: This allows the rank to come through with the results. The search should be sanitized and therefore ok to use like this
  def options_with_rank(options, mysql_match_term, search_text, default_select = ["*"])
    ModelUtil.add_selects!(options, *default_select)
    ModelUtil.add_selects!(options, *["(#{mysql_match_term.gsub("?","'#{search_text}'")}) as rank"])
    
    options
  end

  # Matches start by matching question->profiles, but now we match Profile->questions
  # and only where the question has less than @@question_match_max_prefetch matches or
  # profile rank is greater than the min(rank) for that question
  def rematch_for_profile_text_index(pti)

    return # THIS IS NOW DISABLED! handled async

    # return if !pti.profile.active?
    # 
    # query_text = ''
    # query_text << prep_text_for_match_query(pti.profile_text) if pti.profile_text
    # query_text << ' . '+prep_text_for_match_query(pti.all_answers_text) if pti.answers_text
    # mysql_match_term = 'match (qti.question_text) against (?)'
    # 
    # #Profile.transaction do
    # 
    #   # for existing question matches, rematch to see if rank changes or if we are excluded
    #   # this assumes we are matched to a reasonable number of questions
    #   ps = db_prepare("select question_id from question_profile_matches where profile_id=?")
    #   ps.execute(pti.profile_id)
    # 
    #   while rs = ps.fetch
    #     match_question_to_profiles(Question.find(rs[0]))
    #   end
    #   ps.close
    # 
    #   # attempt to find new questions we match on in an optimized fashion using
    #   # reverse profile->questions matching
    #   ps = db_prepare("select qti.question_id, #{mysql_match_term} as match_rank"+
    #     " from question_text_indices qti"+
    #     " join questions q on q.id=qti.question_id"+
    #     " left join question_profile_matches qpm on qpm.question_id=q.id and qpm.profile_id=?"+
    #     " left join question_profile_exclude_matches qpcm on qpcm.question_id=q.id and qpcm.profile_id=?"+
    #     " left join answers a on a.question_id=q.id and a.profile_id=?"+
    #     # ignore questions we're already matched to
    #     # dont match to those we have marked as ignore
    #     # or those that we have already answered
    #     " where qpm.question_id is null and qpcm.question_id is null and a.question_id is null"+
    #     # only match open questions
    #     " and q.open_until>current_date()"+
    #     " and q.profile_id!=?"+
    #     " and #{mysql_match_term}"+
    #     # only match to questions where we will be in the top [prefetch] list
    #     " and exists (select min(qpm.rank) as min_rank, max(qpm.order) as max_order from question_profile_matches qpm where qpm.question_id=q.id having min_rank<match_rank or max_order<?)")
    # 
    #   ps.execute(query_text,pti.profile_id,pti.profile_id,pti.profile_id,pti.profile_id,query_text,@@question_match_max_prefetch)
    #   while rs = ps.fetch
    #     match_question_to_profiles(Question.find(rs[0])) #!O we could do a reorder or insert
    #   end
    #   ps.close
    # #end
  end

  public

  # utility methods
  def generate_top_terms(num_classes=5,num_terms=100)
    rawdb = ActiveRecord::Base.clone_connection.raw_connection
    rawdb.query_with_result = false

    ttc = TopTermCalculator.new(self,num_classes,num_terms)
    puts '[generate_top_terms] Generating questions terms...'
    #!I doesn't include new q.matchable_text method, maybe join qti
    rawdb.query('select q.question from questions q where current_date()<q.open_until or q.answers_count>0').use_result.each { |rs|      
      ttc.add_text(rs[0])
    }
    ttc.commit('questions')

    ttc.reset
    puts '[generate_top_terms] Generating profiles terms...'
    rawdb.query('select p.profile_text, p.answers_text from profile_text_indices p').use_result.each { |rs|
      ttc.add_text(rs[0])
      ttc.add_text(rs[1])
    }
    ttc.commit('profiles')

    rawdb.close

  end

  def rebuild_indices(*args)

    args = [:group,:profile,:question,:blog_post,:getthere_booking] if args.size==0
    which = Set.new(args)

    rawdb = ActiveRecord::Base.clone_connection.raw_connection
    rawdb.query_with_result = false

    if which.member?(:profile)
      ProfileTextIndex.delete_all
      res = rawdb.query('select * from profiles').use_result
      res.each_hash { |rs|
        p = Profile.new(rs)
        p.id = rs['id']
        profile_updated(p,true)
      }
      res.free
    end

    if which.member?(:group)
      GroupTextIndex.delete_all
      res = rawdb.query('select * from groups').use_result
      res.each_hash { |rs|
        g = Group.new(rs)
        g.id = rs['id']
        group_updated(g)
      }
      res.free
    end

    if which.member?(:question)
      QuestionProfileMatch.delete_all # delete vs destroy
      QuestionTextIndex.delete_all
      res = rawdb.query('select * from questions').use_result
      res.each_hash { |rs|
        q = Question.new(rs)
        q.id = rs['id']
        question_updated(q)
      }
      res.free
    end
    
    if which.member?(:blog_post)
      BlogPostTextIndex.delete_all
      res = rawdb.query('select * from blog_posts').use_result
      res.each_hash { |rs|
        bp = BlogPost.new(rs)
        bp.id = rs['id']
        blog_post_updated(bp)
      }
      res.free
    end

    if which.member?(:getthere_booking)
      GetthereBookingTextIndex.delete_all
      res = rawdb.query('select * from getthere_bookings').use_result
      res.each_hash { |rs|
        gb = GetthereBooking.new(rs)
        gb.id = rs['id']
        getthere_booking_updated(gb)
      }
      res.free
    end

  end

  def run_terms_analysis

    @all_terms = Set.new

    @out = File.new('terms_import.txt','w')

    rawdb = ActiveRecord::Base.clone_connection.raw_connection
    rawdb.query_with_result = false

    def process_text(text)
      return if text.nil?
      text.downcase!
      yield_terms(text) { |term,num_words|
        if @all_terms.add?(term)
          @out.puts term unless weak_term?(term) or suppress_display_terms.member?(term)
        end
      }
    end

    # questions
    res = rawdb.query('select question_text from question_text_indices').use_result
    res.each { |rs|
      process_text(rs[0])
    }
    res.free

    # profiles + answers
    res = rawdb.query('select profile_text, answers_text from profile_text_indices').use_result
    res.each { |rs|
      process_text(rs[0])
      next unless answers_text = rs[1]
      answers_text.gsub!(/\<\/?qa[^\>]*\>/,'')
      process_text(answers_text)
    }
    res.free
    #@out.close

    # if false
    #   profile_text_columns = Set.new
    #   # trying 2 methods
    #   if true
    #     profile_text_columns.merge('question_1,question_2,question_3,question_4,question_8,question_12'.split(','))
    #     # suspect
    #     profile_text_columns.merge('question_7,question_9,profile_7'.split(','))
    #   else
    #     res = rawdb.query("select column_name from information_schema.columns where table_schema='#{ActiveRecord::Base.connection.current_database}' and table_name='profiles' and data_type in ('varchar','text')").use_result
    #     res.each { |rs|
    #       profile_text_columns.add(rs[0])
    #     }
    #     res.free
    #     profile_text_columns.subtract(['profile_5','profile_6','profile_4','alt_first_name','alt_last_name','first_name','last_name'])
    #   end
    # 
    #   #@out = File.new('term_candidates.txt','w')
    #   res = rawdb.query("select #{profile_text_columns.to_a.join(',')} from profiles").use_result
    #   res.each { |rs|
    #     rs.each { |col|
    #       next if col.nil?
    #       col.downcase!
    #       col.split(',').each { |term|
    #         term.strip!
    #         next if term.nil? or term.index(' ').nil?
    #         if @all_terms.add?(term)
    #           @out.puts term unless SemanticMatcher.get_phrase_hash.member?(term)
    #         end
    #       }
    #     }
    #   }
    #   res.free
    # end

    @out.close

  end

  def get_expertise

    pk = {}
    ps = db_prepare("select qr.profile_id, q.question, count(1) from question_referrals qr join questions q on qr.question_id=q.id group by qr.profile_id, q.id")
    ps.execute
    while rs = ps.fetch

      pid = rs[0].to_i
      question = rs[1]
      times_referred = rs[2].to_i

      knowledge = pk[pid]||={}
      get_terms_set(question).each do |term|
        knowledge[term] = knowledge.fetch(term,0)+times_referred
      end

    end
    ps.close

    pk.each_pair do |pid,tc|
      #wca = []
      tc.each_pair do |term,count|
        puts "#{pid},#{count},#{term}"
        #wca << "#{term} (#{count})" #if count>1
      end
      #wca.sort!
      #puts "#{pid},\"#{wca.join(',')}\"" if wca.size>0
    end
    nil
  end

end

class TopTermCalculator

  def initialize(semantic_matcher=SemanticMatcher.default,num_classes=5,max_terms=100)
    @wordcounts = Hash.new(0)
    @num_classes = num_classes
    @max_terms = max_terms
    @semantic_matcher = semantic_matcher
  end

  def reset
    @wordcounts = Hash.new(0)
  end

  def add_text(text)
    text = @semantic_matcher.text_index_text_prep(text)
    @semantic_matcher.yield_terms(text) { |term,term_words|
      next if SemanticMatcher.suppress_display_terms.member?(term) or term=='must-eat-at'
      next if @semantic_matcher.weak_term?(term)
      # hack to remove terms where all words are mysql_stop_words --- it somehow detects/ignores these terms
      words = term.split(' ') if term.include?(' ')
      words = term.split('-') if term.include?('-')
      next if words and mysql_ignore(words)
      @wordcounts[term]+=1
    }
  end

  def commit(domain)
    puts "[generate_top_terms] #{@wordcounts.size} unique terms indexed."
    if @wordcounts.size==0
      TopTerm.delete_all(['domain=?',domain])
      return
    end

    @wordcounts = @wordcounts.sort { |a,b| b[1]<=>a[1] }  #!O this could be faster doing num_term passes if wordcounts is large
    @wordcounts = @wordcounts[0..@max_terms]

    min = @wordcounts[-1][1]
    max = @wordcounts[0][1]

    num_terms = @wordcounts.size < @max_terms ? @wordcounts.size : @max_terms

    # we implement two types of rank algorithms

    # for equal words per rank state, biased to actual usage, but not guaranteed
    bucket_size = (num_terms/(@num_classes+1))+1
    rank_state = @num_classes+1

    # for actual rank based on usage, not as pretty - esp on small sets
    divisor = ((max-min) / @num_classes ) + 1

    TopTerm.transaction do
      TopTerm.delete_all(['domain=?',domain])
      @wordcounts[0..num_terms].each_index do |i|
        tarr = @wordcounts[i]
        rank_state-=1 if (i%bucket_size)==0
        TopTerm.new do |t|
          t.term = tarr[0]
          t.rank = rank_state
          #t.rank = ((tarr[1] - min) / divisor) + 1
          t.domain = domain
          t.save!
        end
      end
    end
  end

  # these are terms mysql will ignore outright, so showing these terms
  # for purposes of searching will return an empty result.
  def mysql_ignore(words)
    return false unless words
    return true if superset?(@semantic_matcher.mysql_stop_words,words)
    # if all words are #'s ignore it
    words.each do |word|
      return false unless word.match(/\d+/)
    end
    true
  end

  def superset?(set,enum)
    enum.each do |e|
      return false unless set.member?(e)
    end
    true
  end

end
