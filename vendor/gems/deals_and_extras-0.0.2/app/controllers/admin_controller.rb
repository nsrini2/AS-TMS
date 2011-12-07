class AdminController < ApplicationController # < ActionController::Base

  allow_access_for [:all] => :content_admin

  def index
  end

end
