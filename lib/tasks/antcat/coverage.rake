# frozen_string_literal: true

namespace :antcat do
  desc 'Run RSpec with coverage (shortcut: `rake cov`)'
  task :coverage do
    sh "rm -rf ./coverage"
    sh "COVERAGE=y rspec"
    sh "xdg-open ./coverage/index.html"
  end
end
task cov: :'antcat:coverage' # Shortcut.
