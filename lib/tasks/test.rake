# frozen_string_literal: true

task(:test).clear
desc 'Run linters and tests (shortcut: `rake t`)'
task :test do # rubocop:disable Rake/DuplicateTask
  puts "Running rubocop...".blue
  system "rubocop"
  puts "Running yarn lint...".blue
  system "./bin/yarn lint"
  puts "Running haml-lint...".blue
  system "haml-lint"

  puts "Running rspec...".blue
  system "rspec"
  puts "Running cucumber...".blue
  system "cucumber"

  puts "Running brakeman...".blue
  system "brakeman -q --no-pager --summary"
  puts "Running bundle audit...".blue
  system "bundle audit check --update"
end
task t: :test # Shortcut.
