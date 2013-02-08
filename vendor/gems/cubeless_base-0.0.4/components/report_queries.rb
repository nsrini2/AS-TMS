class ReportQueries

# stats summary page

## questions summary table

  @@active = 'status = 1'

  def self.open_questions
    db_number('select count(1) from questions q where q.open_until>current_date()')
  end

  def self.matched_open_questions
    db_number("select count(1) from questions q where q.open_until>current_date() and exists (select 1 from question_profile_matches qpm where qpm.question_id=q.id and qpm.order<=#{SemanticMatcher.question_match_max_assigned} limit 1)")
  end

  def self.unmatched_open_questions
    open_questions - matched_open_questions
  end

  def self.open_questions_with_answers
    db_number('select count(1) from questions q where q.open_until>current_date() and exists (select 1 from answers where question_id=q.id limit 1)')
  end

  def self.open_questions_without_answers
    open_questions - open_questions_with_answers
  end

  def self.number_of_removes
    db_number('select count(1) from question_profile_exclude_matches')
  end

  def self.total_questions
    db_number('select count(1) from questions')
  end

  def self.questions_with_answers
    db_number('select count(1) from questions q where exists (select 1 from answers where question_id=q.id limit 1)')
  end

  def self.questions_without_answers
    total_questions - questions_with_answers
  end

  def self.average_time_until_first_answer
    db_number('select avg(TIMESTAMPDIFF(hour,q.created_at,a.created_at)) from questions q join answers a on a.id=(select id from answers where question_id=q.id limit 1)').to_s << " hours"
  end

  def self.average_number_of_answers_per_question
    db_number('select avg((select count(1) from answers a where a.question_id=q.id)) from questions q')
  end

  def self.percent_of_questions_answered_within_1_hour
    "#{total_questions==0 ? 0 : 100*db_number('select count(1) from questions q where exists (select 1 from answers a where a.question_id=q.id and a.created_at <= ADDDATE(q.created_at, INTERVAL 1 HOUR))')/total_questions}%"
  end

  def self.percent_of_questions_answered_within_24_hours
    "#{total_questions==0 ? 0 : 100*db_number('select count(1) from questions q where exists (select 1 from answers a where a.question_id=q.id and a.created_at <= ADDDATE(q.created_at, INTERVAL 1 DAY))')/total_questions}%"
  end

## referrals table

  def self.referrals
    db_number('select count(1) from question_referrals')
  end

  def self.referred_questions
    db_number('select count(distinct(qr.question_id)) from question_referrals qr')
  end

  def self.average_referrals_per_referred_question
    if referrals > 0
      referrals / referred_questions
    else 0
    end
  end

  def self.open_referred_questions
    db_number('select count(distinct(qr.question_id)) from question_referrals qr, questions q where qr.question_id = q.id and q.open_until > curdate()')
  end

  def self.referred_questions_answered_by_the_people_to_whom_they_were_referred
    db_number('select count(distinct(qr.question_id)) from question_referrals qr, answers a where qr.question_id = a.question_id and qr.owner_id = a.profile_id and qr.owner_type="Profile"')
  end

## karma table

  def self.karma_counts
    sums = Karma.karma_level_ranges.collect { |range,level|
      "sum(if(karma_points>=#{range.begin} and karma_points<=#{range.end},1,0))"
    }.join(', ')
    rs = ActiveRecord::Base.connection.execute("select #{sums} from profiles where #{@@active}").first
    data = []
    max_level = Karma.karma_level_ranges.size - 1
    Karma.karma_level_ranges.each_with_index do |range,level|
      data << [Karma.title_for_level(level),"#{range.begin}#{(level == max_level) ? "+" : "-" + range.end.to_s}",rs[level]]
    end
    data
  end

## groups table

  def self.total_groups
    db_number("select count(*) from groups")
  end

  def self.public_groups
    db_number("select count(*) from groups g where g.group_type=0")
  end

  def self.invite_only_groups
    db_number("select count(*) from groups g where g.group_type=1")
  end

  def self.private_groups
    db_number("select count(*) from groups g where g.group_type=2")
  end
  
  def self.total_sponsor_groups
    db_number("select count(*) from groups g where g.sponsor_account_id is not null")
  end

  def self.public_sponsor_groups
    db_number("select count(*) from groups g where g.sponsor_account_id is not null and g.group_type=0")
  end

  def self.invite_only_sponsor_groups
    db_number("select count(*) from groups g where g.sponsor_account_id is not null and g.group_type=1")
  end

  def self.private_sponsor_groups
    db_number("select count(*) from groups g where g.sponsor_account_id is not null and g.group_type=2")
  end


# profile stats page

  def self.total_active_profiles
    # SSJ 2012-4-4 -- I don't like these class variables, but not going to tackle those today.
    @@total_profiles ||= Profile.count(:conditions => @@active )
  end

  def self.total_inactive_profiles
    Profile.count(:conditions => "status = 0")
  end

  def self.total_sponsor_profiles
    Profile.count(:conditions => "roles like '%#{Role::SponsorMember.id}%'")
  end

  def self.reset_total_profiles_cache! #!H see admin_controller
    @@total_profiles = nil
  end

  def self.profiles_with_primary_photo
    db_number("select count(*) from profiles where primary_photo_id is not null and #{@@active}")
  end

  def self.users_with_no_photos
    User.find(:all, :joins => "inner join profiles on profiles.id = users.id",
      :select => [:email], :conditions => ["primary_photo_id is null and #{@@active}"])
  end

  def self.pending_users_emails
    User.find(:all, :joins => "inner join profiles on profiles.id = users.id",
      :select => [:email], :conditions => ["status = 2"])
  end

  def self.profiles_pending_activation
    db_number("select count(1) from profiles p where p.status = 2")
  end

  def self.profiles_with_complete_biz_card_info
    questions = Profile.profile_biz_card_questions
    list = Profile.get_question_list_containing_attr_value(questions, 'completes_profile', true)
    cond = list.collect {|f|
      f == "email" ? nil : "length(p.#{f})>0"
    }.compact.join(' and ')
    db_number("select count(1) from profiles p where #{cond} and p.#{@@active}")
  end

  def self.profiles_with_complete_complex_info
    questions = Profile.profile_complex_questions
    list = Profile.get_question_list_containing_attr_value(questions, 'completes_profile', true)
    cond = list.collect {|f|
      f == "email" ? nil : "length(p.#{f})>0"
    }.compact.join(' and ')
    db_number("select count(1) from profiles p where #{cond} and p.#{@@active}")
  end

  def self.completed_profiles_with_minimum_1_photo
    questions = Profile.get_questions_from_config
    list = Profile.get_question_list_containing_attr_value(questions, 'completes_profile', true)
    cond = list.collect {|f|
      f == "email" ? nil : "length(p.#{f})>0"
    }.compact.join(' and ')
    db_number("select count(distinct(p.id)) from profiles p, attachments a where a.type='ProfilePhoto' and a.owner_id=p.id and #{cond} and p.#{@@active}")
  end

  # MM2: iConfig makes setting class variables a bad idea
  # @@profile_field_labels = Profile.get_questions_from_config

  def self.profile_completion
    fields = Profile.profile_complete_fields
    values = []
    fields.each do |field|
      break if field == "email"
      break if Profile.get_questions_from_config[field].nil?
      populated = Profile.count(:conditions => "#{field} is NOT NULL AND #{@@active}")
      percent = (100*populated/total_active_profiles).to_s + "%"
      values << [Profile.get_questions_from_config[field]['label'], percent]
    end
    values.compact
  end

# top 10 report page

  @@top_x_primary_conditions = "u.id = p.user_id and p.#{@@active}"

  def self.top_x_inquirers
    get_top_x("select p.screen_name,count(1) as total_questions, p.id from questions q,users u,profiles p where q.profile_id = p.id and #{@@top_x_primary_conditions} group by q.profile_id order by total_questions desc")
  end

  def self.top_x_answerers
    get_top_x("select p.screen_name,count(1) as total_answers, p.id from answers a,users u,profiles p where a.profile_id = p.id and #{@@top_x_primary_conditions} group by a.profile_id order by total_answers desc")
  end

  def self.top_x_referrers
    get_top_x("select p.screen_name,count(qr.owner_id) as total_referrals, p.id from question_referrals qr,users u,profiles p where qr.referer_id = p.id and #{@@top_x_primary_conditions} group by qr.referer_id order by total_referrals desc, u.id")
  end

  def self.top_x_karma
    get_top_x("select p.screen_name,p.karma_points, p.id from users u,profiles p where #{@@top_x_primary_conditions} order by p.karma_points desc")
  end

  def self.top_x_largest_groups
    rank = 0
    groups = Group.all(:select => "groups.name, groups.group_memberships_count", :order => "groups.group_memberships_count desc", :limit => 10 )
    groups.collect {|g| [rank+=1, "<a href='/groups/#{g.id}'>#{g.name}</a>","#{g.group_memberships_count}"]}
  end

  def self.top_x_most_active_bloggers
    get_top_x("select p.screen_name,count(1) as total_posts, p.id from blog_posts bp, users u, profiles p where bp.creator_id=p.id and #{@@top_x_primary_conditions} group by bp.creator_id order by total_posts desc")
  end

  def self.top_x_most_active_group_bloggers
    get_top_x("select p.screen_name,count(1) as total_posts, p.id from blog_posts bp, blogs b, users u, profiles p where bp.creator_id=p.id and bp.blog_id=b.id and b.owner_type='Group' and #{@@top_x_primary_conditions} group by bp.creator_id order by total_posts desc")
  end

  def self.top_x_most_active_groups
    rank = 0
    groups = Group.find(:all, :select => "groups.id, groups.name, groups.activity_points", :conditions => ["activity_points > 0"], :order => "activity_points desc", :limit => 10)
    groups.collect {|g| [rank+=1, "<a href='/groups/#{g.id}'>#{g.name}</a>","#{g.activity_points}"]}
  end

  def self.top_x_most_helpful
    get_top_x("select p.screen_name, count(1) as helpful, p.id from votes v, profiles p, answers a where v.owner_id=a.id and a.profile_id = p.id and v.vote_value = 1 group by p.id order by helpful desc")
  end

  def self.top_x_most_unhelpful
    get_top_x("select p.screen_name, count(1) as unhelpful, p.id from votes v, profiles p, answers a where v.owner_id=a.id and a.profile_id = p.id and v.vote_value = 0 group by p.id order by unhelpful desc")
  end

  def self.get_top_x(query_string, limit=10) ## default to 10 since that's what we're primarily using this for
    data = []
    rank = 0
    query_string << " limit #{limit}"
    rawdb.query(query_string).each { |row|
      data << [rank+=1,"<a href='/profiles/#{row[2]}'>#{row[0]}</a>",row[1]]
    }
    data
  end

  def self.db_number(sql)
    # MM2: Must use an class that INHERITS from ActiveRecord::Base. Any class will do.
    # ActiveRecord::Base.count_by_sql(sql)
    CustomReport.count_by_sql(sql)
  end

  def self.rawdb
    ActiveRecord::Base.connection.raw_connection
  end

end
