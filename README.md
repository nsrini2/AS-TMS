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

4 - rake db:create   
  a - delete 'db/seeds.rb' if it exists

5 - rake db:setup

6 - rails c    

7 - rails s
