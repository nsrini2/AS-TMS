class QuestionReferralsController < ApplicationController
  deny_access_for :all => :sponsor_member

  def new
    respond_to do |format|
      format.js { render(:partial => 'questions/question_refer_popup', :layout=> '/layouts/popup', :locals => { :question_id => params[:question_id] }) }
    end
  end

  def create
    referral = params[:question_referral]
    refer_to = find_by_type_and_id(referral[:suggestion_type], referral[:suggestion_id])
    question = Question.find(referral[:question_id])
    question_referral = QuestionReferral.create(:question => question, :owner => refer_to, :referer => current_profile)
    respond_to do |format|
      format.json {
        if question_referral.errors.size > 0
          add_to_errors(question_referral)
          render(:text => { :errors => flash[:errors] }.to_json)
          flash[:errors] = nil
        else
          render(:text => question_referral.to_json(:methods => :referred_to_name))
        end
      }
    end
  end

  def auto_complete_for_referral
    name = params[:q]
    profiles = Profile.exclude_sponsor_members.active.limit(20).find_by_full_name(name)
    groups = Group.find_by_full_name_and_type(name, [0,1], :limit => 20)
    results = (profiles + groups).sort{|x,y| x.full_name <=> y.full_name }
    render :partial => 'shared/name_suggestions', :locals => {:suggestions => results}
  end

end