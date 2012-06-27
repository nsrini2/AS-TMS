# This will guess the user class
FactoryGirl.define do
  Factory.define :company do |f|
    f.name "Factory Company"
    f.description "Factory Company Description"
  end  
  
  
  Factory.define :user do |f|
    f.sequence(:login) { |n| "factory_login#{n}" }   
    f.password "foobar"  
    f.password_confirmation { |u| u.password }
    f.email "factory.user@sabre.com"
  end
    
  # This will guess the Profile class
  Factory.define :profile do |f|
    f.first_name"Bob"
    f.last_name "Jones"
    f.screen_name "BJones"
    f.association :user 
  end
  
  
  Factory.define :company_profile, :class => Profile do |f|
    f.screen_name "CompanyProfileBJones"
    f.association :company
  end  
  
  Factory.define :group do |f|
    f.name "Factory Group"
    f.description "Factory Group Description"
    f.tags "Factory Group Tags"
  end  
  
  
  Factory.define :blog_post do |f|
    f.title "GroupBlogPost Title"
    f.text "GroupBlogPost Text"
    f.tag_list "GroupBlogPost tag list"
    f.association :profile
  end  
  
  Factory.define :blog do |f|
    
  end
  
  Factory.define :note do |f|
    f.message "Factory note message"
  end 
    
  Factory.define :post do |f|
    f.topic_id "1"
    f.author_id "1"
    f.body "Factory Post Body"
  end
  
  Factory.define :question do |f|
    f.category "Life"
    f.question "This is the spec factory question"
    f.open_until Time.now.advance(:months => 1)
    f.association :profile
  end
  
  Factory.define :answer do |f|
    f.answer "This is the spec factory answer"
    f.profile_id "1"
    f.association :profile
  end
  
  Factory.define :comment do |f|
    f.text "This is the factory comment"
    f.association :profile
  end  

  Factory.define :abuse do |f|
    f.reason "Factory abuse reason"
  end  
  
  Factory.define :group_post do |f|
    f.post "Factory GroupPost"
    f.association :profile
    f.association :group
  end  
  
  # # This will use the User class (Admin would have been guessed)
  # factory :admin, :class => User do
  #   first_name 'Admin'
  #   last_name  'User'
  #   admin true
  # end
  # 
  # # The same, but using a string instead of class constant
  # factory :admin, :class => 'user' do
  #   first_name 'Admin'
  #   last_name  'User'
  #   admin true
  # end
end