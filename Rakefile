require File.expand_path('../config/application', __FILE__)
require 'rake'
lll{%q{1}}

AntCat::Application.load_tasks

lll{%q{2}}
unless Rails.env.production?
  require 'cucumber/rake/task'
  require 'rspec/core/rake_task'

lll{%q{3}}
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec, "Run normal specs") do |t|
    lll{%q{3.1}}
    Rake::Task['db:test:prepare'].invoke
    t.rspec_opts = '--tag ~slow'
lll{%q{4}}
lll{%q{5}}
lll{%q{6}}
  end
  task('spec:all').clear
lll{%q{7}}
  RSpec::Core::RakeTask.new('spec:all', "Run normal and slow specs") do |_|
    Rake::Task['db:test:prepare'].invoke
lll{%q{8}}
  end

lll{%q{9}}
  task(:cucumber).clear
  Cucumber::Rake::Task.new :cucumber, "Run current features" do |t|
    Rake::Task['db:test:prepare'].invoke
    t.cucumber_opts = "--tags ~@dormant"
lll{%q{10}}
  end
  task('cucumber:all').clear
  Cucumber::Rake::Task.new('cucumber:all', "Run normal and dormant features") do |_|
    Rake::Task['db:test:prepare'].invoke
lll{%q{11}}
  end

lll{%q{12}}
  desc "Run all tests and features"
  task :all => ['spec:all', 'cucumber:all']
lll{%q{13}}
end
