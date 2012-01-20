require File.expand_path('../config/application', __FILE__)
require 'rake'

AntCat::Application.load_tasks

unless Rails.env.production?
  require 'cucumber/rake/task'
  require 'rspec/core/rake_task'

  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec, "Run normal specs") do |t|
    Rake::Task['db:test:prepare'].invoke
    t.rspec_opts = '--tag ~slow'
  end
  task('spec:all').clear
  RSpec::Core::RakeTask.new('spec:all', "Run normal and slow specs") do |_|
    Rake::Task['db:test:prepare'].invoke
  end

  task(:cucumber).clear
  Cucumber::Rake::Task.new :cucumber, "Run current features" do |t|
    Rake::Task['db:test:prepare'].invoke
    t.cucumber_opts = "--tags ~@dormant"
  end
  task('cucumber:all').clear
  Cucumber::Rake::Task.new('cucumber:all', "Run normal and dormant features") do |_|
    Rake::Task['db:test:prepare'].invoke
  end

  desc "Run all tests and features"
  task :all => ['spec:all', 'cucumber:all']
end
