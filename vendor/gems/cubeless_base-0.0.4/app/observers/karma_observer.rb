class KarmaObserver < ActiveRecord::Observer

  observe Profile, Answer, Vote, Comment

  def before_create(model)
    # must do before_create b/c after_save on Answer deletes all QuestionReferrals
    return unless model.is_a?(Answer)
    return if model.profile_id==model.question.profile_id # any action by the question author is ignored

    # +2 to question author when reach 3 answers (answer author is not question author)
    Profile.add_karma!(model.profile_id,2) if Answer.count_by_sql(['select count(1) from answers where question_id=? and profile_id!=?',model.question_id,model.question.profile_id])==3

    num_answers_for_answerer = Answer.count_by_sql(['select count(1) from answers where question_id=? and profile_id=?',model.question_id,model.profile_id])
    # +3 to a question referrer on first answer by referee
    if num_answers_for_answerer==1
      QuestionReferral.find(:all,:conditions => ['question_id=? and owner_id=?',model.question_id,model.profile_id]).each do |qr|
        Profile.add_karma!(qr.referer_id,3)
        Profile.add_karma!(model.question.profile_id,1)
      end
    end

  end

  @@vote_vote_points = [0,0,1,1,2,3]
  @@monitor_after_create = Set.new([Vote,Comment])
  def after_create(model)
    return unless @@monitor_after_create.member?(model.class)
    case model
      when Comment
          Profile.add_karma!(model.owner.profile_id,1) if (model.owner_type=='Post' || model.owner_type=='BlogPost')
        when Vote
          if model.owner_type=='Answer'
            # READ! could use the new answer.num_pos_votes, but it is incremented in another after_create, and order is not predictable
            positive = model.vote_value
            votes = positive ? model.owner.num_positive_votes : model.owner.num_negative_votes
            points = votes<=5 ? @@vote_vote_points[votes] : positive ? (votes%2) : -5*((votes+1)%2)
            return if points==0
            Profile.add_karma!(model.owner.profile_id,points)
          end
    end
  end

  def before_update(model)
    return unless model.class==Profile
    return if model.completed_once || !model.complete?
    model.completed_once = true
    model.karma_points+=5
  end

  def after_update(model)
    return unless model.class==Answer
    if model.best_answer and model.attribute_modified?(:best_answer)
      num_points = Answer.count_by_sql(['select count(1) from answers where question_id=? and profile_id!=? and profile_id!=?',model.question_id,model.profile_id,model.question.profile_id])
      Profile.add_karma!(model.profile_id,num_points>5 ? 5 : num_points) if model.best_answer and model.attribute_modified?(:best_answer)
    end
  end

  def self.recalc_karma!

    ActiveRecord::Base.connection.raw_connection.query(<<-EOF
update profiles p set karma_points=
(
p.karma_login_points +
if(p.completed_once=1,5,0) +
ifnull(( select sum(2) from questions q where q.profile_id=p.id and (select count(1) from answers a where a.question_id=q.id and a.profile_id!=p.id)>=3 ),0) +
ifnull(( select sum(least(5,(select count(1) from answers a2 where a2.question_id=q.id and a2.profile_id!=p.id and a2.profile_id!=q.profile_id))) from questions q join answers a on q.id=a.question_id and a.best_answer=1 where a.profile_id=p.id ),0) +
ifnull(( select sum( if(num_positive_votes<5,interval(num_positive_votes,2,3,4,4,5),7+floor((num_positive_votes-5)/2)) - if(num_negative_votes<5,interval(num_negative_votes,2,3,4,4,5),7+((num_negative_votes-5)*5)) ) from answers where profile_id=p.id  ),0) +
ifnull(( select sum(3) from question_referrals qr where qr.referer_id=p.id and exists(select 1 from answers a where a.question_id=qr.question_id and a.profile_id=qr.owner_id) ),0) +
( select count(1) from questions q join question_referrals qr on qr.question_id=q.id where q.profile_id=p.id and exists(select 1 from answers a where a.question_id=q.id and a.profile_id=qr.owner_id) ) +
( select count(1) from blog_posts bp join comments c on c.owner_type='BlogPost' and c.owner_id=bp.id where bp.profile_id=p.id and c.profile_id!=p.id) +
( select count(1) from posts join comments c on c.owner_type='Post' and c.owner_id=posts.id where posts.profile_id=p.id and c.profile_id!=p.id)
)
    EOF
)
  end

end