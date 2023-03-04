# frozen_string_literal: true

desc 'Run basic linters (shortcut: `rake l`)'
task :lint do
  puts "Running rubocop...".blue
  system "rubocop"

  puts "Running eslint...".blue
  system "./bin/yarn lint"

  puts "Running haml-lint...".blue
  system "haml-lint"
end
task l: :lint # Shortcut.

desc 'Run other linters (shortcut: `rake lo`)'
task :lint_others do
  puts "Running brakeman...".blue
  system "brakeman -q --no-pager --summary"

  puts "Running bundle audit...".blue
  system "bundle audit check --update"
end
task lo: :lint_others # Shortcut.

desc 'Run all linters (shortcut: `rake ll`)'
task :lint_all do
  Rake::Task["lint"].execute
end
task ll: :lint_all # Shortcut.
