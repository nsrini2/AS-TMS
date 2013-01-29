module VideosHelper
  
  def display_video(video)
    # %{
    #   <video src="#{remote_video_url(video, :video_format => ".mp4")}">
    #     #{embed(video)}
    #   </video>
    # }
    if video.encoded
      embed(video)
    else
      still_encoding
    end
  end
  
  def embed(video)
    %{
    <object width="500" height="330" type="application/x-shockwave-flash" data="/flowplayer/flowplayer-3.1.5.swf" id="player_api">
      #{embed_param "movie", "/flowplayer/flowplayer-3.1.5.swf" }
      #{embed_param "allowfullscreen", "true"}
      #{embed_param "quality", "high"}
      #{embed_param "bgcolor", "#000000"}
      <param name="flashvars" value="#{flowplayer_config(video)}" />
      <embed type="application/x-shockwave-flash" src="/flowplayer/flowplayer-3.1.5.swf" flashvars="#{flowplayer_config(video)}"></embed> 
    </object>    
    }
  end
  
  def still_encoding
    explanation_link = link_to("What does this even mean?", encoding_info_videos_path, :class => "encoding_info")
    
    content_tag("div", "Video has not finished<br/>the encoding process.<br/><small>#{explanation_link}</small>", :class => "encoding-missing")
  end
  
  def embed_param(name, value)
    "<param name=\"#{name}\" value=\"#{value}\" />"
  end
  
  def flowplayer_config(video)
    # playlist: [ 
    # 
    #     // show album cover 
    #     {url: 'album_cover.jpg', scaling: 'orig'}, 
    # 
    #     // our MP3 does not start automatically 
    #     {url: 'my_song.mp3', autoPlay: false} 
    # 
    # ]
    %{
      config={'playlist':[{'url':'#{CGI.escape(remote_image_video_url(video))}'},{'url':'#{CGI.escape(remote_video_url(video))}','autoPlay':false,'autoBuffering':false}]}
    }.strip
  end
  
  def video_actions(video, options={})
		actions = []
		actions << link_to('edit', edit_video_path(video)) if video.editable_by?(current_profile)
		actions << link_to('delete', video_path(video), :confirm => 'Are you sure?', :method => :delete) if video.editable_by?(current_profile)
		actions << "<span class=\"tags\">Tags: #{ link_to_video_tags(video.tag_list) }</span>" if options[:tags] && !video.tag_list.blank?     
		actions
  end
  
end
