# frozen_string_literal: true

if ENV["COVERAGE"]
  require 'simplecov'

  puts "Starting SimpleCov for RSpec"

  SimpleCov.command_name "rspec"
  SimpleCov.start do
    enable_coverage :branch
  end
end
