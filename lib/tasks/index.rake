# rake environment index:all

namespace :index do
  # rake environment index:profiles
  desc "Update Profiles index"
  task :profiles do
    puts "Indexing profiles"
    ENV['CLASS']="Profile"
    ENV['FORCE']="true"
    Rake::Task["tire:import"].reenable
    Rake::Task["tire:import"].invoke
  end
  
  desc "Update Groups index"
  task :groups do
    puts "Indexing groups"
    ENV['CLASS']="Group"
    ENV['FORCE']="true"
    Rake::Task["tire:import"].reenable
    Rake::Task["tire:import"].invoke
  end
  
  desc "Update BlogPosts index"
  task :blog_posts do
    puts "Indexing blog_posts"
    ENV['CLASS']="BlogPost"
    ENV['FORCE']="true"
    Rake::Task["tire:import"].reenable
    Rake::Task["tire:import"].invoke
  end
  
  desc "Update Questions index"
  task :questions do
    puts "Indexing questions"
    ENV['CLASS']="Question"
    ENV['FORCE']="true"
    Rake::Task["tire:import"].reenable
    Rake::Task["tire:import"].invoke
  end
  
  desc "Update Chats index"
  task :chats do
    puts "Indexing chats"
    ENV['CLASS']="Chat"
    ENV['FORCE']="true"
    Rake::Task["tire:import"].reenable
    Rake::Task["tire:import"].invoke
  end
  
  # rake environment index:all
  desc "Update all indices"
  task :all => [:profiles, :groups, :blog_posts, :questions, :chats] do
    puts "Updated all indices"
  end

end