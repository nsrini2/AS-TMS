class AboutUsController < ApplicationController

  allow_access_for :all => :content_admin

  def create
    if params[:commit] != "Remove"
      AboutUs.get.update_attributes params[:object]
      add_to_notices "About Us content has been saved"
    elsif params[:commit] == "Remove"
      AboutUs.get.update_attributes(:content => "")
      add_to_notices "About Us content is now blank"
    end
    redirect_to about_us_admin_path
  end

end