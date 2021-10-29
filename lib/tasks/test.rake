# frozen_string_literal: true

task(:test).clear
desc 'Run linters and tests'
task :test do # rubocop:disable Rake/DuplicateTask
  system "rubocop"
  system "haml-lint"

  system "rspec"
  system "cucumber"

  system "brakeman -q --no-pager --summary"
  system "bundle audit check --update"
end
task t: :test # Shortcut.
