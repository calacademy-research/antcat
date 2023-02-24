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
end
task t: :test # Shortcut.
