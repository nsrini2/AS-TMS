class CommentsController < ApplicationController
  before_filter :identify, :set_parents, :except => [:show]
  deny_access_for :show => :sponsor_member
  deny_access_for [:new, :create, :edit, :update, :index] => :sponsor_member, :when => lambda{|c| c.instance_variable_get(:@root_parent).is_a?(Profile) }

  def new
    show_in_popup 'comment_popup'
  end

  def show
    comment = Comment.find(params[:id])
    if comment.company?
      # SSJ 10/4/2011 -- all compnay comments are on blog posts
      redirect_to "/companies/blog/blog_posts/#{comment.owner.id}#comment#{comment.id}"
    else
      owner = comment.owner  
      options = []
      options << owner.root_parent if owner.respond_to?(:root_parent)
      options << owner.group if owner.is_a?(GalleryPhoto)
      options << :blog if owner.respond_to?(:blog)
      options << owner
      redirect_to polymorphic_path(options)
    end  
  end

  def create
    comment = Comment.new(:text => params[:comment][:text], :owner => @owner, :author => current_profile)
    
    respond_to do |format|
      format.js {
        render :update do |page|
          if comment.save
            page.call 'cClick'
            page.select(".#{@owner.class.name.underscore}.#{@owner.id} .comment_link").each do |div|
              page.replace_html div, :inline => link_to_view_comments(@owner.reload)
            end
            page.select(".#{@owner.class.name.underscore}.#{@owner.id} .comments").each do |div|
              page.replace_html div, :partial => @owner.comments
            end
          else
            replace_flash_error_for(page, comment, :overlayFlashError)
          end
        end        
      }
      format.html {
        if comment.save
          redirect_to url_for(@owner), :notice => "Comment saved."
        else
          redirect_to url_for(@owner), :notice => "There was an error saving your comment."
        end
      }
      
    end

  end

  def edit
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.js { render(:partial => 'edit_comment_popup', :layout => '/layouts/popup') if is_editable?(@comment) }
    end
  end

  def update
    @comment = Comment.find(params[:id])
    if is_editable?(@comment)
      respond_to do |format|
        format.json {
          if @comment.update_attributes(params[:comment])
            render :text => @comment.to_json
          else
            add_to_errors(@comment)
            render :text => { :errors => flash[:errors] }.to_json
            flash[:errors] = nil
          end
        } 
      end
    end
  end
  
  def destroy
    comment = Comment.find(params[:id])
    Rails.logger.info "DELETING COMMENT #{comment.id}"
    comment.destroy
    render :json => ""
  end

  def index
    @comments = @owner.comments
    render :update do |page|
      class_selectors = @owner.respond_to?(:owner) ? ".#{@owner.owner.class.name.underscore}.#{@owner.owner.id} " : ""
      class_selectors << ".#{@owner.class.name.underscore}.#{@owner.id}"
      page.select("#{class_selectors} .comment_link").each do |div|
        page.replace_html div, :inline => link_to("#{comment_or_reply(@owner).pluralize} (#{@comments.size})", "javascript:void(0)", :onclick => "$$('#{class_selectors} .comments').each(function(c){c.toggle();})")
      end
      page.select("#{class_selectors} .comments").each { |div| page.replace_html div, :partial => @comments }
    end
  end

  private

  def set_parents
    @owner = params[:gallery_photo_id].blank? ? parent : GalleryPhoto.find(params[:gallery_photo_id])
    @root_parent = @owner.respond_to?(:root_parent) ? @owner.root_parent : @owner
  end

end