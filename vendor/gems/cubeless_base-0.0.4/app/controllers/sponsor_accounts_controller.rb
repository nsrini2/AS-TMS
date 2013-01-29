class SponsorAccountsController < ApplicationController
  layout 'sponsor_accounts_sub_menu'

  allow_access_for :all => :sponsor_admin

  def index
    @sponsor_accounts = SponsorAccount.all
  end

  def new
    @sponsor_account = SponsorAccount.new
  end

  def edit
    @sponsor_account = SponsorAccount.find( params[:id] )
  end

  def create
    @sponsor_account = SponsorAccount.create( params[:sponsor_account] )
    redirect_to sponsor_accounts_path
  end

  def update
    @sponsor_account = SponsorAccount.find( params[:id] )
    @sponsor_account.update_attributes( params[:sponsor_account] )
    redirect_to sponsor_accounts_path
  end
  
  def delete
    @sponsor_account = SponsorAccount.find( params[:id] )
  end

  def destroy
    @sponsor_account = SponsorAccount.find( params[:id] )
    if params[:commit] == 'Yes'
      name = @sponsor_account.name
      @sponsor_account.destroy
      add_to_notices "#{name} Sponsor Account was deleted."
    end
    redirect_to sponsor_accounts_path
  end

end