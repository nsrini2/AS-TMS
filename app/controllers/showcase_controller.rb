require 'will_paginate/array'
class ShowcaseController < ApplicationController
  deny_access_for :all => :sponsor_member

  def index
    @sponsor_accounts=SponsorAccount.all
    @random_marketing_message = ShowcaseMarketingMessage.random_active_message
    @showcase_text=ShowcaseText.get
  end

  def category_level_details
    @sponsor_account = SponsorAccount.find(params[:id])
    @category_groups=category_filtered_groups(@sponsor_account.id).paginate(:page => params[:groups_page], :per_page => 10)
    @events=ActivityStreamEvent.find_by_category(@sponsor_account.id,:all,:page=> params[:events_page])
  end
end
