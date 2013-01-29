# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
# require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
# require 'spec'
# require 'spec/rails'
# require 'spec/autorun'


# require File.expand_path("../../config/environment", __FILE__)
require File.expand_path("../../../../../config/environment", __FILE__)
require 'rspec/rails'



RSpec.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  # config.mock_with :rspec

  # def login_as_admin
  #   controller.stub!(:current_user => mock_model(User, :profile => mock_model(Profile, :is_admin? => true, :is_sponsored? => false), :uses_login_pass? => false))
  #   controller.stub!(:current_profile => controller.send(:current_user).profile)
  #   controller.current_profile.stub!(:role_keys).and_return([])
  # end
  
  def login_as_cubeless_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'cubeless_admin', :roles => Role::CubelessAdmin) )
  end
  
  def login_as_report_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'report_admin', :roles => Role::ReportAdmin) )
  end
  
  def login_as_content_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'content_admin', :roles => Role::ContentAdmin) )
  end
  
  def login_as_shady_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'shady_admin', :roles => Role::ShadyAdmin) )
  end
  
  def login_as_user_admin
    stub_current_user_and_profile( create_user_and_profile(:login => 'user_admin', :roles => Role::UserAdmin) )
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

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

require File.expand_path(File.dirname(__FILE__) + "/mailer_spec_helper")