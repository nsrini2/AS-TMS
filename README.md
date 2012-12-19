Set up:

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
    bundle install
    (fix any errors)

6 - setup database
    # rake db:drop if you want to redo this section
    rake db:create
    rake db:setup

6 - rails c
    (address any errors)

7 - rails s
    (see it run)

8 - login to website  
    u: cubeless_admin  p: abc123
    u: agent_a         p: abc123