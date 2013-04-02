class BoothVideosController < ApplicationController
  before_filter :init_booth_video
  before_filter :find_booth_details

 def show
    #@original_video = @group_video.panda_video
    #@h264_encoding = @original_video.encodings["h264"]
    render :template => 'booth_video/booth_video', :layout => 'sponsored_group_manage_sub_menu'
  end

  def new
    @video = BoothVideo.new
    render :layout => 'sponsored_group_manage_sub_menu'
  end

  def create
    @video = BoothVideo.create!(params[:video])
    redirect_to :action => :show, :id => @video.id 
  end

  def init_booth_video
     @group = Group.find(params[:group_id])
     @group_video=@group.booth_video
  end

  def find_booth_details
    @group = Group.find(params[:group_id])
    @group_links = @group.group_links.all
     max_id = Group.count_by_sql("select min(profile_id) from (select profile_id from group_memberships where group_id = #{@group.id} order by profile_id desc limit 200) as x")
    @booth_members = @group.members.all(:conditions => "profiles.id >= #{rand(max_id)+1}", :limit => 20).to_a.sort! { |a,b| rand(3)-1 }
  end

  
end
