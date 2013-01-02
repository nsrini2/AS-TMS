#Set up:

1 - git clone   

2 - create local files

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
    
#Cached Objects
Because some classes get overridden in development mode, you must set caching to true to work use these files.  Some notable areas include:

       My Agency -- Companies::HubController
       Search -- ChatTopicIndex
       
To turn on caching in development:

    config/environments/development.rb
    # change line 8 from:
    config.cache_classes = false 
    # to
    config.cache_classes = true
    
Note:  You will need to restart your server instance to see changes in code base when this is set to true.
