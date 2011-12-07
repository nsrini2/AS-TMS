class ReportsController < ApplicationController

  def show
    unless params[:id]
      render :text => "nothing"
    else
      offers = [Offer.find(params[:id])]
      output = FavoritesReport.new.to_pdf offers, params["title"] || nil, params["by"] || nil, params["phone"] || nil, params["website"] || nil, params["agency"] || nil

      respond_to do |format|
        format.html do
          send_data output, :filename => "favorites.pdf", 
                            :type => "application/pdf"
        end
      end
    end
  end

   def favorites
    per_page = params[:per_page] || 6
    page = params[:page] || 1

    offers = current_user.favorites.active.paginate(:per_page => per_page, :page => page)

    output = FavoritesReport.new.to_pdf offers, params["title"] || nil, params["by"] || nil, params["phone"] || nil, params["website"] || nil, params["agency"] || nil

    respond_to do |format|
      format.html do
        send_data output, :filename => "favorites.pdf", 
                          :type => "application/pdf"
      end
    end
  end

  def prepare
    # require "CGI"
    puts params

    uri = params["p"]
    uri = params[:id] if uri.blank?
    
    @loc = (uri.split("?")[0]).html_safe
    p params
    p = CGI.parse(uri.split("?")[1])
    @per_page = p["per_page"][0]
    @page = p["page"][0]
    @id = p["id"][0]
    
    render :layout => nil
  end

end