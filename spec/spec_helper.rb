# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  
  # This will pick up all of the fixtures defined in spec/fixtures into your
  # database and you'll be able to test with some sample data 
  # (eg. Countries, States, etc.)
  config.global_fixtures = :all
  
  def login_as_cubeless_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'cubeless_admin', :roles => Role::CubelessAdmin) )
  end
  
  def login_as_report_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'report_admin', :roles => Role::ReportAdmin) )
  end
  
  def login_as_content_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'content_admin', :roles => Role::ContentAdmin) )
  end

  def login_as_user_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'user_admin', :roles => Role::UserAdmin) )
  end
  
  def login_as_shady_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'shady_admin', :roles => Role::ShadyAdmin) )
  end
    
  def login_as_awards_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'awards_admin', :roles => Role::AwardsAdmin) )
  end
  
  def login_as_sponsor_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'sponsor_admin', :roles => Role::SponsorAdmin) )
  end
  
  def login_as_direct_member
    stub_current_user_and_profile( create_user_and_profile(:login => 'direct_member', :roles => Role::DirectMember) )
  end
  
  def login_as_sponsor_member
    stub_current_user_and_profile( create_user_and_profile(:login => 'sponsor_member', :roles => Role::SponsorMember) )
  end
  
  def stub_current_user_and_profile(profile)
    controller.stub!(:current_user => profile.user)
    controller.stub!(:current_profile => profile)
  end
  
  def create_user_and_profile(options)
    u = User.new
    u.login = options[:login] || 'test_user'
    
    if User.find_by_login(u.login)
      u = User.find_by_login(u.login)
    end
    
    u.password = 'T3st_user'
    u.email = 'test_user@cubeless.com'
    u.terms_accepted = true
    u.save

    
    p = Profile.new
    
    if u.profile && !u.profile.new_record?
      p = u.profile
    else
      p.user = u
    end
    
    p.screen_name = options[:screen_name] || 'test_user'
    p.first_name = options[:first_name] || 'Test'
    p.last_name = options[:last_name] || 'User'
    p.status = options[:status] || 1
    p.visible = options[:visible] || true
    
    # Reset all roles
    p.roles = []
    
    p.save

    # Add roles
    p.add_roles(options[:roles] || Role::DirectMember)
    
    p.save
    
    return p
  end
  
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}