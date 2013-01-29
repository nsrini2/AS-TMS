class AddDefaultMarketingImagesAndPaths < ActiveRecord::Migration
  def self.up
    execute "truncate marketing_messages"
    execute "delete from attachments where type='MarketingImage'"

    execute "alter table `marketing_messages` change column `default` `is_default` tinyint(1) default 0"
    add_column :marketing_messages, :image_path, :string

    marketing_message = MarketingMessage.new(:is_default => 1, :active => 1, :link_to_url => '/explorations/new', :image_path => 'explore')
    marketing_message.save!

    marketing_message = MarketingMessage.new(:is_default => 1, :active => 1, :link_to_url => '/profile', :image_path => 'karma')
    marketing_message.save!

    marketing_message = MarketingMessage.new(:is_default => 1, :active => 1, :link_to_url => '/profile', :image_path => 'notes')
    marketing_message.save!

    marketing_message = MarketingMessage.new(:is_default => 1, :active => 1, :link_to_url => '/explorations/questions', :image_path => 'qa')
    marketing_message.save!
  end

  def self.down
    MarketingMessage.delete_all "is_default = 1"

    remove_column :marketing_messages, :image_path
    execute "alter table `marketing_messages` change column `is_default` `default` tinyint(1) default 0"
  end
end
