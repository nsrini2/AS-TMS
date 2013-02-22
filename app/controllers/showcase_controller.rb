class ShowcaseController < ApplicationController

def index
  @sponsor_accounts=SponsorAccount.all
  @random_marketing_message = MarketingMessage.random_active_message
end

end
