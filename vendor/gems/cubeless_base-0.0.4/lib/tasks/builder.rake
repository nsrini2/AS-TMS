require 'rake/clean'

namespace :build do
    CLOBBER.include('out', 'doc/rspec_report.html')
    desc "Verify that rcov coverage"
    task :verify_rcov do
      threshold = 90;
      total_coverage = nil
      warnings = []
      File.open('coverage/index.html').each_line do |line|
        if line =~ /<tt class='coverage_total'>(\d+\.\d+)%<\/tt>/
          total_coverage = eval($1)
          break
        end
      end
      warnings << "Coverage must be at least #{threshold}% but was #{total_coverage}%" if total_coverage < threshold
    end
  
  desc "Task to do some preparations for CruiseControl"
  task :prepare => [:clobber] do
    mkdir_p "out" if ! File.exist?("out")
    RAILS_ENV = 'test'
  end
  
  desc "Task for CruiseControl.rb"
  task :cruise => [:prepare, "db:migrate", "spec:rcov", "verify_rcov"] do
      out = ENV['CC_BUILD_ARTIFACTS'] || 'out'
      mv 'coverage', "#{out}/test_coverage"
      mv 'doc/rspec_report.html', "#{out}"
  end
end

