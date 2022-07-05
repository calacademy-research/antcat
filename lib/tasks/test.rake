# frozen_string_literal: true

task(:test).clear
desc 'Run linters and tests (shortcut: `rake t`)'
task :test do # rubocop:disable Rake/DuplicateTask
  system "rubocop"
  system "haml-lint"
  system "./bin/yarn lint"

  system "rspec"
  system "cucumber"

  system "brakeman -q --no-pager --summary"
  system "bundle audit check --update"
end
task t: :test # Shortcut.
