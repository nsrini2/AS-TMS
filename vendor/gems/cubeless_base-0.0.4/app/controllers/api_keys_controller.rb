class ApiKeysController < ApplicationController
  before_filter :api_enabled?
  deny_access_for :all => :sponsor_member
  def create
    current_profile.enable_api!

    respond_to do |format|
      format.html { redirect_to '/api' }
    end
  end

  def destroy
    current_profile.disable_api!

    respond_to do |format|
      format.html { redirect_to '/api' }
    end
  end
  
  protected
  def api_enabled?
    Config[:api_enabled]
  end
end