require 'yaml'

class AddGroupEmailPreferencesToGroupMemberships < ActiveRecord::Migration
  def self.up
    add_column :group_memberships, :email_preferences_yaml, :text

    def self.is_true?(blah)
      blah == true || blah == 1 ? true : false
    end

    GroupMembership.all.each do |membership|
      m = membership.member

      membership.email_preferences_yaml = YAML::dump({
        "note" => is_true?(m.group_note_email_status),
        "blog_post" => is_true?(m.group_blog_post_email_status),
        "group_talk_post" => is_true?(m.group_post_email_status),
        "referred_question" => is_true?(m.group_referral_email_status)
      })
      membership.save
    end
  end

  def self.down
    remove_column :group_memberships, :email_preferences_yaml
  end
end
