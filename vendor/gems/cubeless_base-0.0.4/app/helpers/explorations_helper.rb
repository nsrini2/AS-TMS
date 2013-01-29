module ExplorationsHelper
  include VideosHelper

  def link_to_blog_tag(owner, tag, count=false)
    name = tag.is_a?(Tag) ? tag.name : tag
    total = count && tag.is_a?(Tag) && tag.attributes['total']
    link_to name + (count ? " (#{total})" : ""), "#{blogs_explorations_path}?query=#{name}"
  end

  def link_to_blog_tags(owner, tags)
    result = []
    tags.sort.each do |tag|
      result << link_to_blog_tag(owner, tag)
    end
    result.join(', ')
  end
  
  def link_to_video_tag(tag, count=false)
    name = tag.is_a?(Tag) ? tag.name : tag
    total = count && tag.is_a?(Tag) && tag.attributes['total']
    link_to name + (count ? " (#{total})" : ""), "#{videos_explorations_path}?query=#{name}"
  end

  def link_to_video_tags(tags)
    result = []
    tags.sort.each do |tag|
      result << link_to_video_tag(tag)
    end
    result.join(', ')
  end

end