require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

namespace :cucumber do
  Cucumber::Rake::Task.new(:selenium, "Run features that use Selenium") do |t|
    t.profile = 'selenium'
  end
end

# add to default tasks (not override)
task :default => [:cucumber, 'cucumber:selenium']
