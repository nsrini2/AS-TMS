require 'benchmark'

# flush all std output immediately (for tailing)
$stdout.sync ||= true
$stderr.sync ||= true

namespace :bam do
  desc 'Create SSO user'
  task(:create_sso_user => :environment) do
    u = User.new
    u.email = 'joseph.savard@sabre.com'
    u.terms_accepted = true
    u.sync_exclude = true
    u.sso_id = ENV['sso_id'] || 'test_id'
    u.save
    p = Profile.new(:screen_name => 'SSO User', :first_name => 'SSO', :last_name => 'User', :user => u, :status => 1, :visible => 1)
    p.save
    u.save
  end

  desc 'Create cubeless_admin user'
  task(:create_cubeless_admin => :environment) do
    u = User.find_or_initialize_by_login('cubeless_admin')
    u.email = 'support@cubeless.com'
    u.terms_accepted = true
    u.sync_exclude = true
    u.save
    p = Profile.find_or_initialize_by_screen_name(:screen_name => 'Cubeless Admin', :first_name => 'Cubeless', :last_name => 'Admin', :user => u, :status => 1, :visible => 0)
    p.add_roles(Role::CubelessAdmin, Role::ReportAdmin, Role::ContentAdmin, Role::ShadyAdmin, Role::UserAdmin, Role::AwardsAdmin, Role::SponsorAdmin)
    p.save
    u.password = '$abre90T00th45'
    u.save
  end

  desc 'Generate dynamic css for the install'
  task(:generate_css => :environment) do
    CSS.new.generate
  end

  desc 'Generate explore page terms'
  task(:generate_top_terms => :environment) do
    SemanticMatcher.default.generate_top_terms
  end

  desc 'Rematch all open questions'
  task(:rematch_questions => :environment) do
    SemanticMatcher.default.rematch_questions
  end

  desc 'Rebuild all text indices'
  task(:rebuild_indices => :environment) do
    SemanticMatcher.default.rebuild_indices
  end

  desc 'Sync sabre users'
  task(:sync_sabre_users => :environment) do
    SyncSabreUsersToBambora.new.sync_all
  end

  desc 'Run terms analysis'
  task(:run_terms_analysis => :environment) do
    SemanticMatcher.default.run_terms_analysis
  end

  desc 'Update group activity'
  task(:update_group_activity => :environment) do
    Group.update_activity
  end

  desc 'Remove closed questions from referred questions'
  task(:remove_closed_question_referrals => :environment) do
    QuestionReferral.remove_closed
  end
  
  desc 'query getthere for new/updated bookings'
  task(:query_getthere_bookings, :forced_user_login, :needs => :environment) do |t, args|
    DirectDataQuery.query_getthere_bookings args[:forced_user_login]
  end
  
  desc 'delete past getthere bookings'
  task(:delete_past_getthere_bookings => :environment) do
    Getthere.delete_past_bookings
  end

  desc 'Daily Maintenance'
  task(:daily => :environment) do
    Profile.purge_data_if_deactivated!(15)
    Notifier.send_close_reminder
    Notifier.send_daily_summary_emails
    Notifier.send_question_summary
    Group.update_activity

    Group.update_all('no_memberships_on=curdate()','group_memberships_count=0 and no_memberships_on is null')
    Group.update_all('no_memberships_on=null','group_memberships_count>0 and no_memberships_on is not null')
    Group.destroy_all('group_memberships_count=0 and no_memberships_on is not null and no_memberships_on<DATE_SUB(CURDATE(),INTERVAL 14 DAY)')

    QuestionReferral.remove_closed
    Notifier.send_question_match_notifications
    
    SemanticMatcher.default.generate_top_terms
  end

  desc 'Weekly Maintenance'
  task(:weekly => :environment) do
    Notifier.send_weekly_summary_emails
    # Getthere.delete_past_bookings
  end

  desc 'Hourly Maintenance'
  task(:hourly => :environment) do
    Video.update_encodings if Video.enabled?

    # WatchEvent.delete_old_events!(20)
    # SemanticMatcher.default.generate_top_terms
  end

  desc 'Periodic Maintenance'
  task(:periodic => :environment) do
    SemanticMatcher.default.rematch_questions
    
    # Instead of keeping 40 stream events, we now keep 72 hours worth OR 40 events...whichever is greater
    ActivityStreamEvent.cleanup_old_events(:records_to_keep => 50, :earliest_date_to_keep => Time.now.advance(:hours => -72).utc)
    
    Visitation.remove_additional!('Group',21)
    Visitation.remove_additional!('Profile',48)
    # DirectDataQuery.query_getthere_bookings
    
    # pull RSS feeds
    RssFeed.pull_to_blogs
  end
  
  desc 'Run Queued User Sync Job'
  task(:run_user_sync_job => :environment) do
    puts Benchmark.measure {
      UserSyncJob.instance.run
    }
  end

#  task(:test => :environment) do
#    SemanticMatcher.default.match_groups
#  end

end
