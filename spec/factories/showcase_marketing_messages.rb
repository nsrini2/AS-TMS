# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :showcase_marketing_message do
    active false
    link_to_url "MyText"
  end
end
