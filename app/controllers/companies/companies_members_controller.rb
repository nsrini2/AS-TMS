class Companies::MembersController < ApplicationController
  before_filter :current_company, :set_selected_tab
  layout "_company_tabs"
  
  def index
    @members = @company.members.paginate(:page => params[:page], :per_page => 20)
  end
  

private
  def set_selected_tab
    @company_members_tab_selected = "selected"
  end
  
end