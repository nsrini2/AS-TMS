source 'http://rubygems.org'
# SSJ 2012-8-2 I modified the Gemfile.lock directly to use the most current version of 
# rack, 1.4.1.  This is so the production server can run both rails 3.0.16 and 3.2.7 applications
# so if you update teh Gemfile.lock, please keep this in mind
# test in developmnet in a rack based server, like Thin to ensure this is not broken

gem 'rails', '3.0.16'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem "sass"

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'


# Not ready yet
# gem 'exception_notification'

gem "RedCloth", '4.2.3'
gem 'rmagick', '2.5.2'

gem "json", '1.2.4'

# require native mysql driver, not the ruby version
gem 'fastercsv', '1.5.4' # admin user import/export
gem 'mysql', '2.8.1'

# MM2
# The s3 and right_aws gems must come before the rest-client/microreviewr gems
# Bad things happen if it doesn't
# Is that super scary? Yes.
gem 's3', '0.2.6'
# gem 'right_aws', '2.0.0'

# gem 'rest-client', :lib => 'rest_client', :version => '1.5.0'

gem "rest-client", '1.6.1'
gem "hashie", '>= 0.4.0'
gem "microreviewr", :require => 'microreview', :path => 'vendor/gems/microreviewr-0.1.2'

gem 'panda', '0.2.1'

gem 'capistrano', '2.5.18'

gem 'delayed_job', '~>2.1.4'
gem 'spawn'

gem 'koala', '1.2.1'

gem 'compass', '0.10.6'
gem 'compass-960-plugin', '0.10.0'

gem 'will_paginate', "~> 3.0.pre2"

# TNSS Engines
gem 'cubeless_base', '0.0.4', :path => 'vendor/gems/cubeless_base-0.0.4'
gem 'ruport'
gem 'acts_as_reportable'

gem 'deals_and_extras', '0.0.2', :path => 'vendor/gems/deals_and_extras-0.0.2'

gem 'devise', '1.3.1'
gem 'ym4r'
gem 'hpricot'
gem 'prawn'
gem 'feedzirra', '~> 0.1.2'
gem 'inherits_from', '~> 0.0.2'
gem 'newrelic_rpm', '~> 3.3.4.1' 

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'ruby-debug'
  gem 'seed_me'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rcov'
  # from app folder $> thin start
  gem 'thin'  
  # gem 'ruby-prof'
end

