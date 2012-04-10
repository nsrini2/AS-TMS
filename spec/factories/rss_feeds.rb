# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rss_feed do
    blog_id 1
    profile_id 1
    feed_url "http://www.test_rss_feed.com"
    last_etag "MyString"
    description "This is the factory rss_feed description"
    # tagline "Test Tagline"
    active 1
  end
end
