class CssController < ApplicationController

  caches_page :screen
  skip_before_filter :require_auth
  skip_before_filter :require_terms_acceptance
  layout nil
  session :off

  @@theme_colors = Config[:themes][Config[:theme]]

  def screen
    params[:stylefile] = 'screen'
    css
  end

  def subdir
    params[:stylefile] = params[:subdir] + "/" + params[:stylefile]
    css
  end

  def css
    @stylefile = params[:stylefile]
    if @stylefile
      @stylefile.gsub!(/.css$/, '')
      @stylefile = "/css/" + @stylefile + ".rcss"
      @theme_colors = @@theme_colors
      render :file => @stylefile, :use_full_path => true, :content_type => "text/css"
    else
      render :nothing => true, :status => 404
    end
  end
end
