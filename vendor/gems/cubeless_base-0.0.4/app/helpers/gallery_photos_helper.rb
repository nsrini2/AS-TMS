module GalleryPhotosHelper
  def rate_gallery_photo(gallery_photo, rating)
    options = {:class => "selected"} if (gallery_photo.user_has_rated ? gallery_photo.user_rating == rating : gallery_photo.rating_avg.round == rating)
    link_to(rating, rate_group_gallery_photo_path(:group_id => gallery_photo.group_id, :id => gallery_photo.id, :rating => rating), options)
  end
end