class GalleryPhotosController < ApplicationController
  layout 'group'

  before_filter :group_up_and_protect_privates
  before_filter :find_booth_details
  before_filter :clean_tags, :only => [:create, :update]

  def new
    return redirect_to(group_gallery_photos_path(@group)) unless @group.is_member?(current_profile)
    respond_to do |format|
      format.js { render :layout => '/layouts/_popup' }
    end
  end

  def index
    @photos = @group.gallery_photos.all(gallery_photo_filters)
    render :layout => '/layouts/sponsored_group' if @group.is_sponsored?
  end

  def update
    @photo = GalleryPhoto.find( params[:id] )
    @photo.update_attributes( params[:gallery_photo] )
    respond_to do |format|
      format.json { render :text => @photo.to_json(:methods => 'tag_list') }
    end
 end

  def create
    return redirect_to(group_gallery_photos_path(@group)) unless @group.is_member?(current_profile)
    @photo = GalleryPhoto.new(
      :caption => params[:gallery_photo][:caption],
      :gallery_photo_attachment => GalleryPhotoAttachment.new(params[:asset]),
      :uploader => current_profile,
      :tag_list => params[:gallery_photo][:tag_list],
      :group => @group)

    if params[:asset][:uploaded_data].blank?
      add_to_errors "We need an image for this award"
    else
      if @photo.save
        flash[:notice] = 'Photo was successfully uploaded!'
      else
        add_to_errors "We weren't able to save the photo :("
        add_to_errors "Is the photo less than 2MB and of type JPEG/JPG, GIF, or PNG?"
      end
    end
    redirect_to group_gallery_photos_path(@group)
  end

  def show
    begin
      @comment = Comment.new
      @photo = @group.gallery_photos.find(params[:id])
      render :layout => '/layouts/sponsored_group' if @group.is_sponsored?
    rescue
      redirect_to group_gallery_photos_path(@group) and return if @photo.blank?
    end
  end

  def delete
    @photo = @group.gallery_photos.find(params[:id])
  end

  def destroy
    return redirect_to(group_gallery_photos_path(@group)) unless @group.is_member?(current_profile)
    @photo = @group.gallery_photos.find(params[:id])
    @photo.destroy
    add_to_notices "Photo was successfully deleted."
    redirect_to group_gallery_photos_path(@group)
 end

  def rate
    photo = @group.gallery_photos.find(params[:id])
    photo.rate(params[:rating].to_i, current_profile)
    photo.save
    photo.reload
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render(:partial => 'gallery_photos/rating', :layout => false, :locals => { :gallery_photo => photo } ) }
    end
    if @group.is_sponsored?
      render :layout => '/layouts/sponsored_group'
    end
  end

  def new_comment
    @photo = @group.gallery_photos.find(params[:id])
    @comment = Comment.new(:profile => current_profile, :owner => @photo, :owner_type => 'GalleryPhoto', :text => params[:comment][:text])
    if @comment.save
      redirect_to group_gallery_photo_path(@group, @photo)
    else
      add_to_errors(@comment)
      render :action => 'show'
    end
  end

  private

  def group_up_and_protect_privates
    @group = Group.find_by_id(params[:group_id])
    private_group_protection_needed
  end

  def clean_tags
    params[:gallery_photo][:tag_list] && params[:gallery_photo][:tag_list].tr!("'","")
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
    source=@group.booth_twitter_id
    if !source.nil?
      begin
       @twitter_feed=Twitter.user_timeline("#{source}").first.text
       @twitter_user_name=Twitter.user("#{source}").name
       @twitter_user_handle="@"+Twitter.user("#{source}").screen_name
      rescue => e
       Rails.logger.info("Twitter error: " + e.message)
      end
    end
  end

end
