require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

# We want to be able to run 'rake' and have the Cucumber tests run.
# We want to do this in development mode, even though the tests
# themselves will run in test or cucumber mode. So just swallow it up if
# Cucumber isn't installed
begin
  namespace :cucumber do
    Cucumber::Rake::Task.new(:selenium, "Run features that use Selenium") do |t|
      t.profile = 'selenium'
    end
    desc "Run both plain and enhanced features"
    task :all_features => [:cucumber, 'cucumber:selenium']
  end

  # add to default tasks (not override)
  task :default => ['cucumber:all_features']

rescue NameError
end

begin
  require 'metric_fu'
rescue MissingSourceFile
end
