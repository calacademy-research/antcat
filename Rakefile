require File.expand_path('../config/application', __FILE__)
require 'rake'

unless Rails.env.production?
  require 'cucumber/rake/task'
  namespace :cucumber do
    Cucumber::Rake::Task.new(:plain, "Run features that don't use Selenium") do |t|
      t.profile = 'plain'
    end
    Cucumber::Rake::Task.new(:enhanced, "Run features that use Selenium") do |t|
      t.profile = 'enhanced'
    end
  end

  desc "Run both plain and enhanced Cucumber features"
  task 'cucumber:all_features' => ['cucumber:enhanced', 'cucumber:plain']

  task :default => [:spec, 'cucumber:all_features']

  begin
    require 'metric_fu'
  rescue MissingSourceFile
  end
end

AntCat::Application.load_tasks
