class BoothVideosController < ApplicationController
before_filter :find_booth_details

  def new
    @booth_video = BoothVideo.new
    render :layout => 'sponsored_group_manage_sub_menu'
  end

  def create
    @booth_video = BoothVideo.new(params[:booth_video])
    if params[:marketing_video_file].blank?
       flash[:errors] = "We need a video file for creating this booth video"
       render :action => "new"
    else
       @booth_video.marketing_video=MarketingVideo.new(:uploaded_data => params[:marketing_video_file])
       @booth_video.convert
       #flash[:notice] = 'Video has been uploaded'
       #redirect_to :action => 'show'
       #else
       #render :action => 'new'
    end
  end

  def show
    @video = BoothVideo.find(params[:id])
    render :template => 'booth_video/booth_video', :layout => 'sponsored_group_manage_sub_menu'
  end
  
  def delete
    @video = BoothVideo.find(params[:id])
    @video.destroy
    redirect_to :action => 'show'
  end

  def find_booth_details
    @group = Group.find(params[:group_id])
    @group_links = @group.group_links.all
     max_id = Group.count_by_sql("select min(profile_id) from (select profile_id from group_memberships where group_id = #{@group.id} order by profile_id desc limit 200) as x")
    @booth_members = @group.members.all(:conditions => "profiles.id >= #{rand(max_id)+1}", :limit => 20).to_a.sort! { |a,b| rand(3)-1 }
    @group_blog_tags=TagCloud.tagcloudize(@group.blog.booth_tags.map{|x|x.name + " "})
    if @group_blog_tags.count > 0
      @group_blog_tags.sort!{|a,b|a[:count]<=>b[:count]}
      @minTagOccurs=@group_blog_tags.first[:count]
      @maxTagOccurs=@group_blog_tags.last[:count]
    end
   end
end

