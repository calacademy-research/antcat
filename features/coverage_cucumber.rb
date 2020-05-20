# frozen_string_literal: true

if ENV["COVERAGE"]
  require 'simplecov'

  puts "Starting SimpleCov for Cucumber"

  SimpleCov.command_name "cucumber"
  SimpleCov.start do
    enable_coverage :branch
  end
end
