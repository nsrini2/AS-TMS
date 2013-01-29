module WatchesHelper

  def link_to_unless_current_ignore_params(name, options = {}, html_options = {}, &block)
    (options == request.request_uri.split('?')[0]) ? "<span>#{name}</span>" : link_to(name, options, html_options, &block)
  end

  def render_selected_if_is?(which)
    ' class="selected"' if (params[:id] == which.to_s) || (!params[:id] && which == params[:action])
  end

end