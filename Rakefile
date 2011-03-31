require File.join File.dirname(__FILE__), 'config', 'boot'

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

require 'sunspot/rails/tasks'

namespace :cucumber do
  Cucumber::Rake::Task.new(:plain, "Run features that don't use Selenium") do |t|
    t.profile = 'plain'
  end
  Cucumber::Rake::Task.new(:enhanced, "Run features that use Selenium") do |t|
    t.profile = 'enhanced'
  end
end

desc "Run both plain and enhanced Cucumber features"
task :cucumber => ['cucumber:plain', 'cucumber:selenium']

# add to default tasks (not override)
task :default => :cucumber

begin
  require 'metric_fu'
rescue MissingSourceFile
end
