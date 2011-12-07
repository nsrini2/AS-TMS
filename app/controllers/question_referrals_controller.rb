require_cubeless_engine_file(:controller, :question_referrals_controller)

class QuestionReferralsController < ApplicationController
  def create
    referral = params[:question_referral]
    refer_to = find_by_type_and_id(referral[:suggestion_type], referral[:suggestion_id])
    question = Question.unscoped.find(referral[:question_id])
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

end