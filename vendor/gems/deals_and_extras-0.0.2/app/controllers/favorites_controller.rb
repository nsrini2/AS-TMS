class FavoritesController < ApplicationController
  layout nil

  def index
    # For some reason we keep ending up here...even on post
    if params[:id]
      create and return
    end

    params[:per_page] = params[:per_page] || 20
    
    if logged_in?
      @favorites = current_user.paginate_favorites(params)
      while @favorites.length < 1 && params[:page].to_i > 1
        params[:page] = params[:page].to_i - 1
        @favorites = current_user.paginate_favorites(params)
      end
      @page = params[:page] || 1
      @per_page = params[:per_page]
    else
      @favorites = Favorite.where(:user_id => 0).paginate(:per_page => params[:per_page], :page => params[:page])
    end
  end
  
  def create
    offer = Offer.find(params[:id])
    
    if current_user.offers.include? offer
      current_user.favorites.find_all_by_offer_id(params[:id]).each{ |f|
        f.delete
      }
    else
      current_user.favorites.create(:offer => Offer.find(params[:id]))
    end
    
    puts current_user
    
    render :text => 'ok'
  end

  def destroy
    create
    render :text => 'ok'
  end

  def update
    favorite = Favorite.find(params[:id])
    if current_user.favorites.include?(favorite)
      favorite.update_attributes({ :custom_title => params[:custom_title]})
      favorite.save
    end
    render :text => 'ok'
  end

end
