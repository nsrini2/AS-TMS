require 'will_paginate/array'
class SponsorAccountsController < ApplicationController
  layout 'sponsor_accounts_sub_menu'
  
  allow_access_for :all => :sponsor_admin
  
  def index
    @sponsor_accounts = SponsorAccount.all.paginate(:page => params[:page], :per_page => 3)
  end

  def new
    @sponsor_account = SponsorAccount.new
  end

  def edit
    @sponsor_account = SponsorAccount.find(params[:id])
    if @sponsor_account.showcase_category_image
      @filename = @sponsor_account.showcase_category_image.filename
    end
  end

  def create
   @sponsor_account = SponsorAccount.new(params[:sponsor_account])
   if params[:showcase_category_image_file].blank?
       flash[:errors] = "We need an image for creating this showcase category"
       render :action => "new"
   else
      if @sponsor_account.save
      @sponsor_account.showcase_category_image = ShowcaseCategoryImage.new(:uploaded_data => params[:showcase_category_image_file])
      flash[:notice] = "Showcase category #{@sponsor_account.name} was created!"
      #SRIWW: Redirecting to the last page where the newest category will be displayed
      redirect_to sponsor_accounts_path :page =>  (SponsorAccount.all.count/3.to_f).ceil
    else
       flash[:errors] = @sponsor_account.errors
       render :action => "new"
       params[:showcase_category_image_file].tempfile = nil
    end
   end
  end


  def update
    @sponsor_account = SponsorAccount.find(params[:id])
    @sponsor_account.update_attributes(params[:sponsor_account])
    if @sponsor_account.save
        if params[:showcase_category_image_file] && !params[:showcase_category_image_file].blank?
           #Rails.logger.info("Niranjana filename is:" + @sponsor_account.showcase_category_image.public_filename(:medium).to_s)
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
    @sponsor_account = SponsorAccount.find( params[:id] )
  end


  def destroy
    @sponsor_account = SponsorAccount.find( params[:id] )
    if params[:commit] == 'Yes'
      name = @sponsor_account.name
      @sponsor_account.destroy
      @sponsor_account.showcase_category_image.destroy
      add_to_notices "#{name} Showcase category was deleted."
    end
    redirect_to sponsor_accounts_path
  end

end
