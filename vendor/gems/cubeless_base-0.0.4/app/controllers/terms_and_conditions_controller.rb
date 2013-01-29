class TermsAndConditionsController < ApplicationController

  allow_access_for :all => :content_admin

  def create
    if params[:commit] != "Remove"
      TermsAndConditions.get.update_attributes params[:object]
      add_to_notices "Terms and Conditions content has been saved"
    elsif params[:commit] == "Remove"
      TermsAndConditions.get.update_attributes(:content => "")
      add_to_notices "Terms and Conditions content is now blank"
    end
    redirect_to terms_and_conditions_admin_path
  end

end