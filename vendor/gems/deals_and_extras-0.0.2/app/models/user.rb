class User < ActiveRecord::Base
  
  has_many :favorites
  has_many :offers, :through => :favorites
  
  has_many :reviews
  has_many :reviewed_offers, :class_name => 'Offer', :through => :reviews, :source => :offer
  
  # def self.current
  #   User.first
  # end
  
  def paginate_favorites(params)
    # Favorite.find_all_by_user_id(self.id).paginate(:per_page => params[:per_page], :page => params[:page])
    Favorite.where(:user_id => self.id).active.paginate(:per_page => params[:per_page], :page => params[:page])
  end
  
end