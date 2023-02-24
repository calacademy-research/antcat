# frozen_string_literal: true

desc 'Run linters (shortcut: `rake l`)'
task :lint do
  puts "Running rubocop...".blue
  system "rubocop"
  puts "Running eslint...".blue
  system "./bin/yarn lint"
  puts "Running haml-lint...".blue
  system "haml-lint"

  puts "Running brakeman...".blue
  system "brakeman -q --no-pager --summary"
  puts "Running bundle audit...".blue
  system "bundle audit check --update"
end
task l: :lint # Shortcut.
