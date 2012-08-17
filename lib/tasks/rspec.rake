unless Rails.env.production?
  begin
    require 'rspec'
    require 'rspec/core/rake_task'

    namespace :spec do
      desc "Run engine examples"
      RSpec::Core::RakeTask.new(:engines) do |t|
        t.pattern = 'vendor/gems/cubeless*/spec/**/*.rb'
        t.rspec_opts = %w[--color]
      end
  
      desc "Run all specs, including engines"
      RSpec::Core::RakeTask.new(:all) do |t|
        t.pattern = ['spec/**/*_spec.rb', 'vendor/gems/cubeless*/spec/**/*_spec.rb']
        t.rspec_opts = %w[--color]
      end
  
      namespace :all do
        desc "Run all specs, including engines, with rcov"
        RSpec::Core::RakeTask.new(:rcov) do |t|
          t.rcov = true
      
          # t.rcov_opts = %w{--rails --exclude gems\/,spec\/,features\/}
          include_files = ["app\/"]
          include_files << "lib\/"
          include_files << "vendor\/gems\/cubeless*\/app\/"
          include_files << "vendor\/gems\/cubeless*\/components\/"
          include_files << "vendor\/gems\/cubeless*\/lib\/"
      
          t.rcov_opts = ["--include-file #{include_files.join(",")}", "--rails", "--exclude \.bundle\/,gems\/,spec\/,features\/,vendor\/gems\/cubeless*\/vendor\/", "--spec-only"]
        end

    
        # require 'spec/rake/verify_rcov'
        # 
        # RCov::VerifyTask.new(:verify_rcov => 'spec:rcov') do |t|
        #   t.threshold = 100.0
        #   t.index_html = 'coverage/index.html'
        # end
      end
    end
    task :default => "spec:all"
  rescue
    puts "Unable to load/run rspec.  For details look in file:  #{__FILE__}"
  end  
end  