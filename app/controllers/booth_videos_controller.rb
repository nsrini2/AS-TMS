class BoothVideosController < ApplicationController
before_filter :find_booth_details

  def show
    render :layout => 'sponsored_group_manage_sub_menu'
  end


  def new
    @booth_video = BoothVideo.new
    render :layout => 'sponsored_group_manage_sub_menu'
  end

  def create
    @booth_video = BoothVideo.new(params[:booth_video])
    @booth_video.group_id = params[:group_id]
    if params[:marketing_video_file].blank?
       flash[:errors] = "We need a video file for creating this booth video"
       render :action => "new"
    else
       @booth_video.marketing_video=MarketingVideo.new(:uploaded_data => params[:marketing_video_file])
       @booth_video.save
       Rails.logger.info("Values are: Video - #{@booth_video.marketing_video.public_filename.to_s}")
       #@booth_video.marketing_video.convert
       flash[:notice] = 'Video has been uploaded'
       redirect_to :action => 'show'
    end
  end

  def edit
    @booth_video = BoothVideo.find(params[:id])
    @video_filename = @booth_video.marketing_video.filename
  end

  def update
    @booth_video = BoothVideo.find(params[:id])
    @booth_video.update_attributes(params[:booth_video])
    if @booth_video.save
        if params[:showcase_category_image_file] && !params[:showcase_category_image_file].blank?
           @sponsor_account.showcase_category_image = ShowcaseCategoryImage.new(:uploaded_data => params[:showcase_category_image_file])
        end
        flash[:notice] = "Showcase category #{@sponsor_account.name} was updated!"
        redirect_to sponsor_accounts_path
    else
         flash[:errors] = @sponsor_account.errors
         redirect_to edit_sponsor_account_path(@sponsor_account)
    end
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

