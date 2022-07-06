# frozen_string_literal: true

desc 'Run linters (shortcut: `rake l`)'
task :lint do
  system "rubocop"
  system "./bin/yarn lint"
  system "haml-lint"
end
task l: :lint # Shortcut.
