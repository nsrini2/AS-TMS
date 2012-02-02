# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity_stream_message do
    primary_photo_id 1
    title "MyString"
    description "MyString"
  end
end
