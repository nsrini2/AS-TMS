class OffersController < ApplicationController
  layout nil

  def index
    5.times { Rails.logger.info "----------------" } 
    Rails.logger.info params.inspect
    @page_title = "Offers"
    params[:per_page] = 10
    @offers = Offer.filter(params)
    @current_user = current_user
  end

  def show
    @offer = Offer.find(params[:id])
    respond_to do |f|
      f.html # { render :layout => "main" }
      f.js { render :partial => 'offers/offer', :locals => {:offer => @offer} }
    end
  end

  def book    
    @offer = Offer.find(params[:id])
    @offer_type = if @offer.book_by_sabre?
                    'book_by_sabre_red'
                  elsif @offer.book_by_url?
                    'book_by_url'
                  else
                    ''
                  end
  end

end
