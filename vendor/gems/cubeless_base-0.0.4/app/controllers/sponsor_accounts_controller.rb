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
    @sponsor_account = SponsorAccount.find( params[:id] )
  end

  def create
    if params[:showcase_category_image_file].blank?
       flash[:errors] = "We need an image for creating this showcase category"
       redirect_to new_sponsor_account_path
    else
    @sponsor_account = SponsorAccount.new( params[:sponsor_account] )
    @sponsor_account.showcase_category_image = ShowcaseCategoryImage.new(:uploaded_data => params[:showcase_category_image_file])
    if @sponsor_account.save
        flash[:notice] = "Showcase category #{@sponsor_account.name} was created!"
        redirect_to sponsor_accounts_path
    else
         flash[:errors] = @sponsor_account.errors
         redirect_to new_sponsor_account_path
         params[:showcase_category_image_file].tempfile = nil
    end
   end
  end


  def update
    @sponsor_account = SponsorAccount.find( params[:id] )
    @sponsor_account.update_attributes( params[:sponsor_account] )
    redirect_to sponsor_accounts_path
  end
  
  def delete
    @sponsor_account = SponsorAccount.find( params[:id] )
    #Rails.logger.info("Sponsor account to be deleted:" + @sponsor_account.name)
  end

  def destroy
    @sponsor_account = SponsorAccount.find( params[:id] )
    #Rails.logger.info("Sponsor account to be deleted:" + @sponsor_account.name)
    if params[:commit] == 'Yes'
      name = @sponsor_account.name
      @sponsor_account.destroy
      add_to_notices "#{name} Showcase category was deleted."
    end
    redirect_to sponsor_accounts_path
  end

end
