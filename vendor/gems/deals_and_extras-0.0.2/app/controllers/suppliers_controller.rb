class SuppliersController < ApplicationController
  
  layout 'admin'
  before_filter :__init
  
  def __init
    @nav = 'layouts/suppliers/nav'
  end
  
  def show
    redirect_to suppliers_offers_path
  end
  
end
