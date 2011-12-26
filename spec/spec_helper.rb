# coding: UTF-8

require 'simplecov'
SimpleCov.start 'rails'

require 'spork'
Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  require 'webmock/rspec'
  WebMock.disable_net_connect! :allow_localhost => true

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true
    config.fail_fast = false
  end
end

Spork.each_run do
  FactoryGirl.reload
end

puts "in #{`pwd`}"
