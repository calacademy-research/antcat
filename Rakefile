require_relative 'config/application'
require 'rake'

AntCat::Application.load_tasks

unless Rails.env.production?
  require 'cucumber/rake/task'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new :normal_specs do |t|
    t.rspec_opts = '--tag ~slow'
  end
  RSpec::Core::RakeTask.new(:all_specs)
  Cucumber::Rake::Task.new :current_features do |t|
    t.cucumber_opts = "--tags ~@dormant"
  end
  Cucumber::Rake::Task.new(:all_features)

  task(:spec).clear 
  desc "Run normal specs"
  task :spec => ['db:test:prepare', :normal_specs]
  namespace :spec do
    task(:all).clear 
    desc "Run all specs"
    task :all => ['db:test:prepare', :all_specs]
  end

  task(:cucumber).clear 
  desc "Run current features"
  task :cucumber => ['db:test:prepare', :current_features]
  namespace :cucumber do
    task(:all).clear 
    desc "Run all features"
    task :all => ['db:test:prepare', :all_features]
  end

  desc "Run all tests and features"
  task :all => ['spec:all', 'cucumber:all']
end
