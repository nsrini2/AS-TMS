class ReviewsController < ApplicationController
  layout nil

  def index
    per_page = 3;
    
    @offer = Offer.find(params[:offer_id])
    @reviews = @offer.reviews.verified.paginate(:page => params[:page], :per_page => per_page)
    @current_user = current_user
  end

  def up
    new
    @default = true
    render :new
  end

  def down
    new
    @default = false
    render :new
  end

  def new
    @offer = Offer.find(params[:offer_id])
    @review = Review.new
  end

  def create
    @review = Review.new(params[:review])
    @review[:offer_id] = params[:offer_id]
    
    if logged_in?
      @review['user_id'] = current_user.id
    else
      if current_temp_user
        @review['temp_user_id'] = current_temp_user.id
      else
        temp_user = TempUser.create
        self.current_temp_user = temp_user
        @review['temp_user_id'] = temp_user.id
      end
    end

    if @review.save
      @offer = @review.offer
      
      if @review.temp_user
        render :json => {:status => true, :temp_user => true}
      else
        render :json => {:status => true, :percentage => @offer.percentage, :offer_id => @offer.id}
      end
    else
      render :json => {
        :status => false,
        :errors => render_to_string(:partial => 'errors')
      }
    end
  end

end
