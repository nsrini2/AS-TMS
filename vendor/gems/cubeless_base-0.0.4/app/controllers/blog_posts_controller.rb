class BlogPostsController < ApplicationController
  skip_before_filter :require_auth, :only => [:index]
  skip_before_filter :require_terms_acceptance, :only => [:index]
  before_filter :set_owner, :except => [:show, :rate, :new_comment, :destroy]
  before_filter :clean_tags, :only => [:create, :update]
  deny_access_for :all => :sponsor_member, :when => lambda{|c| c.instance_variable_get(:@owner).is_a?(Profile)}

  def new
    return redirect_to(url_for([@owner, :blog])) if !bloggable?
    @blog_post = BlogPost.new
    @blog = @owner.blog
    render :template => 'blog_posts/new', :layout => @owner.is_a?(Group) ? 'group': '_my_stuff'
  end

  def create
    return redirect_to(url_for([@owner, :blog])) if !bloggable?
    @blog_post = BlogPost.new(params[:blog_post])
    @blog_post.profile = current_profile
    @blog_post.blog = @owner.blog
    if params[:commit]
      if @blog_post.save
        add_to_notices('Your blog post was created!')
        redirect_to @blog_post
      else
        @blog = @owner.blog
        add_to_errors(@blog_post)
        render :template => 'blog_posts/new', :layout => @owner.is_a?(Group) ? 'group': '_my_stuff'
      end
    elsif params[:preview]
      @blog = @owner.blog
      @preview_blog_post = @blog_post
      render :template => 'blog_posts/new', :layout => @owner.is_a?(Group) ? 'group': '_my_stuff'
    else
      redirect_to [@owner, :blog]
    end
  end

  def show
    @blog = BlogPost.find_by_id(params[:id]).blog
    @owner = @blog.owner
    
    if @blog.company?
      redirect_to view_context.companies_blog_blog_post_path(params[:id])
    else
      unless private_group_protection_needed(@owner)
        @blog_posts = [@blog.blog_posts.find_by_id(params[:id])]
        @archives = @blog.archived_posts
        instance_variable_set("@#{@owner.class.name.downcase}", @owner)
        @blog_posts[0].increment_post_views! unless @owner==current_profile
        render :template => 'blogs/show', :layout => @owner.is_a?(Group) ? 'group': '_my_stuff'
      end
    end
  end

  def edit
    @blog_post = BlogPost.find(params[:id])
    @blog = @blog_post.blog
    if is_editable?(@blog_post)
      render :template => 'blog_posts/edit', :layout => @owner.is_a?(Group) ? 'group': '_my_stuff'
    end
  end

  def update
    @blog_post = BlogPost.find(params[:id])
      if is_editable?(@blog_post)
        if params[:commit]
          if @blog_post.update_attributes(params[:blog_post])
            add_to_notices('Blog post successfully updated!')
            redirect_to @blog_post
          else
            @blog = @blog_post.blog
            add_to_errors(@blog_post)
            render :template => 'blog_posts/edit', :layout => @owner.is_a?(Group) ? 'group': '_my_stuff'
          end
        elsif params[:preview]
          @blog_post.title = params[:blog_post][:title]
          @blog_post.text = params[:blog_post][:text]
          @blog_post.tag_list = params[:blog_post][:tag_list]
          @blog = @blog_post.blog
          @preview_blog_post = @blog_post
          render :template => 'blog_posts/edit', :layout => @owner.is_a?(Group) ? 'group': '_my_stuff'
        else
          redirect_to @blog_post
        end
    end
  end

  def destroy
    blog_post = BlogPost.find(params[:id])
    return unless blog_post.deletable_by?(current_profile)
    blog_owner = blog_post.blog.owner
    owner_path = blog_owner.is_a?(Profile) ? profile_blog_path(blog_owner) : group_blog_path(blog_owner)
    blog_post.destroy
    respond_to do |format|
      format.json { render :text => "{\"redirect\" : \"#{owner_path}\"}" }
      format.html { redirect_to owner_path }
    end
  end

  def rate
    blog_post = BlogPost.find(params[:id])
    blog_post.rate(params[:rating].to_i, current_profile)
    blog_post.save(false) #some old posts don't have tags which are now required
    blog_post.reload
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render(:partial => 'blog_posts/rating', :layout => false, :locals => { :blog_post => blog_post } ) }
    end
  end

  def new_comment
    @blog_post = BlogPost.find(params[:id])
    comment = Comment.new(:profile => current_profile, :owner => @blog_post, :owner_type => 'BlogPost', :text => params[:comment][:text])
    if comment.save
      redirect_to "#{blog_post_path(@blog_post)}#comment_#{comment.id}"
    else
      add_to_errors(comment)
      redirect_to blog_post_path(@blog_post) + "#{'?comment='+params[:comment][:text] unless params[:comment][:text].blank?}" + "#new_comment"
    end
  end

  private

  def set_owner
    @owner = parent
  end

  def bloggable?
    (@owner.is_a?(Group) ? @owner.is_member?(current_profile) : current_profile == @owner)
  end
  
  def clean_tags
    params[:blog_post][:tag_list].tr!("'","")
  end
  
end