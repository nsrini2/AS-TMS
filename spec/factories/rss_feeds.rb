# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rss_feed do
    blog_id 1
    profile_id 1
    feed_url "MyString"
    last_etag "MyString"
    description "MyString"
    active 1
  end
end
