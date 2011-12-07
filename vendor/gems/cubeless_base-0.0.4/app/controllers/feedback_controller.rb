class FeedbackController < ApplicationController

  skip_before_filter :require_auth
  skip_before_filter :require_terms_acceptance

  def create
    @feedback = Feedback.new params[:feedback]
    @feedback.name = params[:feedback][:name] || current_profile.screen_name
    @feedback.email = params[:feedback][:email] || current_profile.email
    if @feedback.valid? && Notifier.deliver_feedback(@feedback)
      add_to_notices "Your feedback was successfully sent."
      redirect_to new_feedback_path
    else
      add_to_errors @feedback
      render :action => 'new'
    end
  end

  def new
  end

  def show
    redirect_to new_feedback_path
  end

end