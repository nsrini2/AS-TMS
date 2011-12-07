class OffersController < ApplicationController
  layout nil

  def index
    @page_title = "Offers"
    params[:per_page] = 20
    @offers = Offer.filter(params)
    @current_user = current_user
  end

  def show
    @offer = Offer.find(params[:id])
    respond_to do |f|
      f.html
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
