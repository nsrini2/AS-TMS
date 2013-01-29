class WatchEventObserver < ActiveRecord::Observer
  observe WatchEvent
  def after_create(watch_event)
    if watch_event.watchable.is_a?(Profile) && watch_event.action_item.is_a?(BlogPost) && !watch_event.private?
      recipients = get_subscribers(watch_event)
      BatchMailer.mail(watch_event, recipients) unless recipients.blank?
    end
  end


  private

  def get_subscribers(watch_event)
    options = ["`profiles`.`following_profile_blog_notification` = 1"]
    
    subscriptions = Watch.find_all_by_watchable_id_and_watchable_type(watch_event.watchable_id, watch_event.watchable_type, :joins => "inner join `profiles` on `watches`.`watcher_id` = `profiles`.`id`", :conditions => ["`following_profile_blog_notification` = 1"])
    subscriptions.collect { |subscription| subscription.watcher.email }
  end
end



