# frozen_string_literal: true

namespace :antcat do
  desc 'Run RSpec and Cucumber with coverage'
  task coverage: :environment do
    sh "rm -rf ./coverage"
    sh "COVERAGE=y rspec; COVERAGE=y cucumber"
    sh "xdg-open ./coverage/index.html"
  end
end
