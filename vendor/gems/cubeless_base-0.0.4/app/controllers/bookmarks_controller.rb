class BookmarksController < ApplicationController

  def create
    bookmark = Bookmark.new(:profile => current_profile, :question_id => params[:question_id]).save
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :text => bookmark.to_json }
    end
  end

  def remove
    Bookmark.destroy_by_question_and_profile(params[:id], current_profile.id)
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
end