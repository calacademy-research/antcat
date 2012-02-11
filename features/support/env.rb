# coding: UTF-8
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= "test"
  require_relative '../../config/environment'
  require_relative '../../spec/support/sunspot'

  require 'cucumber/rails'

  Capybara.default_selector = :css

  ActionController::Base.allow_rescue = false

  DatabaseCleaner.strategy = :truncation

  Capybara.save_and_open_page_path = '/tmp'
  Capybara.default_wait_time = 5

  require 'webmock/cucumber'
  WebMock.disable_net_connect! allow_localhost: true

  require 'capybara/firebug'
  require 'factory_girl/step_definitions'
end

Spork.each_run{FactoryGirl.reload}

Sunspot.session = Sunspot.session.original_session if ENV['DRB'] != 'true'
at_exit do
  Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session) if ENV['DRB'] != 'true'
end
