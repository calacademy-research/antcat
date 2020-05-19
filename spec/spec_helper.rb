# frozen_string_literal: true

if ENV["COVERAGE"]
  require 'simplecov'

  SimpleCov.command_name "rspec"
  SimpleCov.start do
    enable_coverage :branch
  end
end
