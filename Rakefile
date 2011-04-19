# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
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
task 'cucumber:all_features' => ['cucumber:plain', 'cucumber:enhanced']

# add to default tasks (not override)
task :default => 'cucumber:all_features'

begin
  require 'metric_fu'
rescue MissingSourceFile
end

Antcat::Application.load_tasks
