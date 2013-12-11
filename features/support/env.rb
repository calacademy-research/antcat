# coding: UTF-8
require 'spork'

require 'factory_girl'
require 'cucumber/formatter/progress'
require 'cucumber/rspec/doubles'

Spork.prefork do
  ENV["RAILS_ENV"] ||= "test"
  require_relative '../../config/environment'

  require 'cucumber/rails'

  Capybara.default_selector = :css

  ActionController::Base.allow_rescue = false

  DatabaseCleaner.strategy = :truncation

  Capybara.save_and_open_page_path = '/tmp'
  Capybara.default_wait_time = 5

  require 'webmock/cucumber'
  WebMock.disable_net_connect! allow_localhost: true
  WebMock.stub_request :put, 'https://antcat.s3.amazonaws.com/1/21105.pdf'
end

Spork.each_run{FactoryGirl.reload}

include Warden::Test::Helpers
Warden.test_mode!

Warden::Manager.serialize_into_session do |user|
  user.email
end

Warden::Manager.serialize_from_session do |email|
  User.find_by_email email
end
