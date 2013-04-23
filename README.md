Set up:

1 - git clone  to create local copy of repo 

2 - create local files and dir structure

    - config/panda.yml
    - config/facebook.yml
    - config/database.yml
    - config/feature_sets.yml
3 - create local folders       

    - public/attachments
    - log
    - tmp

4 - install ImageMagick

5 - install gems

    - bundle install
    - (fix any errors)

6 - setup database

    - rake db:drop  # if you have already create the database
    - rake db:create
    - rake db:migrate
    - rake db:seed

7 - rails c
    
    (address any errors)

8 - rails s
    
    (see it run)

9 - login to website  

    - u: cubeless_admin  p: abc123
    - u: agent_a         p: abc123

Fixes to defect #'s 254, 274, 275, 276

Changes in Agentstream admin (Sponsors tab) as follows:
a) Tab renamed as "Showcase"
b) Included showcase category image as a compulsory input field for creating a new showcase category
c) Fixed delete action for showcase category (defect # 257)
d) Modified name references on these pages so:
      sponsor account => showcase category
      sponsor member => booth owner
      sponsor group (group) => booth


This change includes the following:
----------------------------------------------------------------------------------------------------------------
1. Fixes to defect #'s 277, 280

Defect #277:
-------------
Description: User is able to create a group in any sponsor account even when the 'no of groups allowed' for the
sponsor account is set to 0

Defect #280
-------------
Description: When the user tries to create a group without entering values for the name/desc fields, the group 
is not saved, but a flash notice informs the user that the nameless group has been saved

This change includes the following:
----------------------------------------------------------------------------------------------------------------
1. Changes in Agentstream 'Travel Expo' Admin tab as follows:
a) Added menu for setting Showcase Text
b) Added menu for creating Showcase Marketing Messages

----------------------------------------------------------------------------------------------------------------

2. Changes in 'Travel Expo' (showcase) page
a) Added category level listings page

----------------------------------------------------------------------------------------------------------------
