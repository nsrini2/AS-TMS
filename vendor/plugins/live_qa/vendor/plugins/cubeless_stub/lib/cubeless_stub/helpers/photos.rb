module CubelessStub
  module Helpers
    module Photos

      @@thumb_sizes = {:thumb => '50x50', :thumb_80 => '80x80', :thumb_large => '175x175'}

      def primary_photo_for(model=nil, options={})
        options[:size] ||= @@thumb_sizes[options[:thumb] || :thumb]

        unless options[:hide_tooltip]
          tooltip = model.screen_name if model.is_a?(Profile) && !current_profile.is_sponsored? && model.visible?
        end

        if model.is_a?(Profile) && photo_linkable?(model, options)
          link_opts = { :class => 'photo_link_to' }.merge(options.delete(:link_options) || {})
        end

        content_tag :div, :class => "photo_wrapper" do
          (options[:hide_sponsor_sash] ? "" : sponsor_indicator_for(model).to_s) +
          link_to_if(photo_linkable?(model, options), image_tag(primary_photo_path_for(model, options[:thumb]), :size => options[:size], :alt => "avatar", :class => "photo #{'tooltip' if tooltip}", :title => tooltip), photo_link(model), link_opts) +
          (options[:hide_status_indicator] ? "" : online_indicator_for(model).to_s ) #+
          #(options[:hide_group_icon] || !model.is_a?(Group) ? "" : group_icon(model).to_s)
        end
      end

      def primary_photo_path_for(model=nil, which=nil)
        which ||= :thumb
        model && model.primary_photo_path(which) || generic_photo_path_for(model, which)
      end

      def photo_path_for(model, photo=nil, which=nil)
        which ||= :thumb
        photo ? photo.public_filename(which) : generic_photo_path_for(model, which)
      end

      def link_to_avatar_for(profile, options={})
        primary_photo_for(profile, options.merge(:linkable => true))
      end

      def generic_photo_path_for(model, which=:thumb)
        base_img = "gen_avatar.png"
        # base_img.insert(0, "group_") if model.is_a?(Group)
        base_img.insert(-5, "_large") if which != :thumb
        image_path(base_img)
      end

      protected
      def photo_linkable?(model, options)
        return false unless options[:linkable]
        return false unless model
        return false if model.is_a?(Profile) && (current_profile.is_sponsored? || !model.visible?)
        return true
      end

      def photo_link(model)
        return profile_path(model.id) if model.is_a?(Profile)
        # return group_path(model.id) if model.is_a?(Group)
      end

      def online_indicator_for(model)
        if model.is_a?(Profile) && model.online_now?
          image_tag('onlineNowAvatar.png', :alt=> 'online now', :title=> "#{model.screen_name + ' is ' if !current_profile.is_sponsored? && model.visible?}Online Now", :class=> 'online_now_indicator tooltip', :width=> '17', :height=> '19')
        end
      end

      def sponsor_indicator_for(model)
        if (model.is_a?(Profile) || model.is_a?(Group)) && model.is_sponsored?
          image_tag('sponsor_indicator.png', :alt=> 'sponsor', :title=> "#{model.screen_name + ' is a ' if model.is_a?(Profile) && !current_profile.is_sponsored? && model.visible?}Sponsor", :class=> "sponsor_indicator #{'tooltip' if model.is_a?(Profile)}", :width=> '22', :height=> '13')
        end
      end

    end
  end
end