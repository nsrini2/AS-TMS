# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

u = User.new( :email => 'your.email@sabre.com')
u.login = 'cubeless_admin'
u.password = 'abc123'
u.password_confirmation = 'abc123'
u.terms_accepted = 1
u.sync_exclude = 1
begin
  u.save!
rescue
  u = User.find_by_email('your.email@sabre.com')
end

p = Profile.find_or_create_by_user_id(u.id)
p.user_id = u.id
p.first_name = 'Cubeless'
p.last_name = 'Admin'
p.attributes[:roles] = "1,7,2,8,3,4,0"
p.screen_name = 'cubeless_admin'
p.visible = 0
p.status = 1
begin
  p.save!
rescue e
  puts e
end

u = User.new( :email => 'agent_a.email@sabre.com')
u.login = 'agent_a'
u.password = 'abc123'
u.password_confirmation = 'abc123'
u.terms_accepted = 1
u.sync_exclude = 1
begin
  u.save!
rescue
  u = User.find_by_email('agent_a.email@sabre.com')
end

p = Profile.find_or_create_by_user_id(u.id)
p.first_name = 'Agent'
p.last_name = 'A'
p.attributes[:roles] = "5"
p.screen_name = 'agent_a'
p.visible = 0
p.status = 1
begin
  p.save!
rescue e
  puts e
end

c = SiteConfig.find_or_create_by_site_name('AgentStream')
c.disclaimer = "*Unauthorized use by anyone other than a valid travel agent or approved supplier sponsor, including copying or printing of pictures, personal member information, as well as public sharing or distribution of those materials, is explicitly prohibited.<br />
*The information on this site is the intellectual property of the individual publishers or the opinions of community members.  The views expressed in these articles do not necessarily represent the views of Sabre Holdings, it's businesses, and its partners."
c.terms_acceptance_required = 1
c.open_registration = 1
c.registration_queue = 1
c.theme = "theme_5"
c.feedback_email = 'your.email@sabre.com'
c.email_from_address = 'Developer Testing <no-reply@cubeless.com>'
c.site_base_url = 'http://localhost:3000'
c.api_enabled = 1
c.rank_enabled  = 1
c.monitor_email_address ='your.email@sabre.com'
c.welcome_promo_title_1 = 'welcome all travel agent professionals ...'
c.welcome_promo_1 = "Join the world's largest travel agent community with over 8,500 active members from 122 countries"
c.welcome_promo_title_2 = 'search & share thousands of deals & extras'
c.welcome_promo_2 = "Rate & review thousands of agent-exclusive deals and hard-to-find travel activities and tours."
c.welcome_promo_title_3 = "collaborate <br />& save time."
c.welcome_promo_3 = "Share knowledge and  save valuable time researching & troubleshooting each day. Over 4,000 questions & answers posted to-date."
c.save!

s = SiteProfileCard.create!(:site_profile_field_id => 6, :position => 4, :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 1, :position => -2, :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 4, :position => 2,  :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 5, :position => 1,  :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 6, :position => 1,  :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 1, :position => -2, :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 2, :position => 0,  :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 3, :position => 0,  :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 2, :position => 0,  :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 3, :position => 0,  :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 4, :position => -2, :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 5, :position => -2, :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 7, :position => 6,  :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 7, :position => -2, :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 8, :position => 3,  :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 8, :position => -2, :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 9, :position => 5,  :type => 'SiteProfilePage')
s.type = 'SiteProfilePage'
s.save
s = SiteProfileCard.create!(:site_profile_field_id => 9, :position => -2, :type => 'SiteBizCard')
s.type = 'SiteBizCard'
s.save

SiteProfileField.create!(:label => 'Email',                       :question => 'email',     :completes_profile => 1, :matchable => 1)
SiteProfileField.create!(:label => 'Agency or Company Name',      :question => 'profile_1', :completes_profile => 1, :matchable => 0)
SiteProfileField.create!(:label => 'Tagline',                     :question => 'profile_2', :completes_profile => 1, :matchable => 0)
SiteProfileField.create!(:label => 'Certifications & Languages:', :question => 'profile_3', :completes_profile => 1, :matchable => 0)
SiteProfileField.create!(:label => 'Years in Travel',             :question => 'profile_4', :completes_profile => 1, :matchable => 0)
SiteProfileField.create!(:label => 'Location',                    :question => 'profile_5', :completes_profile => 1, :matchable => 1)
SiteProfileField.create!(:label => 'Twitter ID',                  :question => 'profile_6', :completes_profile => 1, :matchable => 0)
SiteProfileField.create!(:label => 'Your Website',                :question => 'profile_7', :completes_profile => 1, :matchable => 0)
SiteProfileField.create!(:label => 'Agency Booking Type',         :question => 'profile_8', :completes_profile => 0, :matchable => 9)

SiteProfileQuestionSection.create!(:name => 'About My Agency', :position => 1)
SiteProfileQuestionSection.create!(:name => 'On The Job',      :position => 2)
SiteProfileQuestionSection.create!(:name => 'Off The Job',     :position => 3)

SiteProfileQuestion.create!(:label => 'Agency type?',                                                       :question => 'question_1',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>1, :example => "" )
SiteProfileQuestion.create!(:label => 'Your role in the agency?',                                           :question => 'question_2',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>1, :example => "" )
SiteProfileQuestion.create!(:label => 'What you spend your day doing?',                                     :question => 'question_3',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>1, :example => "" )
SiteProfileQuestion.create!(:label => 'What is the best tip you can give a new agent?',                     :question => 'question_4',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>1, :example => "" )
SiteProfileQuestion.create!(:label => 'What products, software, or booking engines do you use daily?',      :question => 'question_5',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>2, :example => "" )
SiteProfileQuestion.create!(:label => 'Who are your favorite travel suppliers and why?',                    :question => 'question_6',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>2, :example => "" )
SiteProfileQuestion.create!(:label => 'What types of travel or destinations do you book the most?',         :question => 'question_7',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>2, :example => "" )
SiteProfileQuestion.create!(:label => 'Who are your customers?',                                            :question => 'question_8',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>2, :example => "" )
SiteProfileQuestion.create!(:label => 'What is your hometown?',                                             :question => 'question_9',  :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>3, :example => "" )
SiteProfileQuestion.create!(:label => 'Why do you love to travel?',                                         :question => 'question_10', :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>3, :example => "" )
SiteProfileQuestion.create!(:label => 'What are your favorite vacation destinations?',                      :question => 'question_11', :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>3, :example => "" )
SiteProfileQuestion.create!(:label => 'Anything else you want to share with other members about yourself?', :question => 'question_12', :completes_profile => 1, :matchable => 1, :site_profile_question_section_id =>3, :example => "" )

SiteQuestionCategory.create!(:name => 'Leisure Travel',         :position => 1)
SiteQuestionCategory.create!(:name => 'Corporate Travel',       :position => 2)
SiteQuestionCategory.create!(:name => 'Marketing',              :position => 3)
SiteQuestionCategory.create!(:name => 'Technology',             :position => 4)
SiteQuestionCategory.create!(:name => 'Suppliers',              :position => 5)
SiteQuestionCategory.create!(:name => 'Industry Events',        :position => 6)
SiteQuestionCategory.create!(:name => 'News & Trends',          :position => 7)
SiteQuestionCategory.create!(:name => 'Accounting/Back Office', :position => 8)

SiteRegistrationField.create!(:label => 'PCC or IATA Number',                   :position => 3,  :required => 1, :options => "",                                                                                        :site_profile_field_id => nil)
SiteRegistrationField.create!(:label => 'Company Name',                         :position => 4,  :required => 1, :options => "",                                                                                        :site_profile_field_id => 2)
SiteRegistrationField.create!(:label => 'Website URL',                          :position => 8,  :required => 1, :options => "",                                                                                        :site_profile_field_id => 8)
SiteRegistrationField.create!(:label => 'Country',                              :position => 5,  :required => 1, :options => "Canada\nUnited States\nOther\n-----",                                                     :site_profile_field_id => 6)
SiteRegistrationField.create!(:label => 'City',                                 :position => 7,  :required => 1, :options => "",                                                                                        :site_profile_field_id => nil)
SiteRegistrationField.create!(:label => 'Registration Type',                    :position => 1,  :required => 1, :options => "Travel Agent\nTravel Supplier (Air, Car, Hotel, Tour, GDS, etc.)",                        :site_profile_field_id => nil)
SiteRegistrationField.create!(:label => 'GDS Affiliation',                      :position => 9,  :required => 1, :options => "Sabre\nAmadeus\nTravelport\nGalileo\nWorldspan\nOther\nI am not affiliated with any GDS", :site_profile_field_id => nil)
SiteRegistrationField.create!(:label => 'Travel Specialization',                :position => 10, :required => 1, :options => "Leisure\nCorporate\nGeneralist (Both Leisure & Corporate)\nOther",                        :site_profile_field_id => 9)
SiteRegistrationField.create!(:label => 'State or Province or Not Applicable',  :position => 6,  :required => 1, :options => "",                                                                                        :site_profile_field_id => nil)
SiteRegistrationField.create!(:label => 'Agency Type',                          :position => 2,  :required => 1, :options => "Home-Based Agency\nRetail Agency",                                                        :site_profile_field_id => nil)

SystemAnnouncement.create!(:content => "<p>Go check out <a href='http://www.twitter.com/#!/search/%23hop'>#HOP</a> at twitter</p>")

b = Blog.new(:owner_id => 2, :owner_type => 'News')
b.save!
b.id = 10
b.save!
# d = Date.today
# p.questions.build(:category => "Marketing", :question => "default seed question?", :open_until => d.advance(:months => 2) )

