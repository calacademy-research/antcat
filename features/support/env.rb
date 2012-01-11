# coding: UTF-8

require 'simplecov'
SimpleCov.start 'rails'

require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= "test"
  require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
  require File.expand_path(File.dirname(__FILE__) + '/../../spec/support/sunspot')

  # IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
  # It is recommended to regenerate this file in the future when you upgrade to a 
  # newer version of cucumber-rails. Consider adding your own code to a new file 
  # instead of editing this one. Cucumber will automatically load all features/**/*.rb
  # files.

  require 'cucumber/rails'

  # Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
  # order to ease the transition to Capybara we set the default here. If you'd
  # prefer to use XPath just remove this line and adjust any selectors in your
  # steps to use the XPath syntax.
  Capybara.default_selector = :css

  # By default, any exception happening in your Rails application will bubble up
  # to Cucumber so that your scenario will fail. This is a different from how 
  # your application behaves in the production environment, where an error page will 
  # be rendered instead.
  #
  # Sometimes we want to override this default behaviour and allow Rails to rescue
  # exceptions and display an error page (just like when the app is running in production).
  # Typical scenarios where you want to do this is when you test your error pages.
  # There are two ways to allow Rails to rescue exceptions:
  #
  # 1) Tag your scenario (or feature) with @allow-rescue
  #
  # 2) Set the value below to true. Beware that doing this globally is not
  # recommended as it will mask a lot of errors for you!
  #
  ActionController::Base.allow_rescue = false

  begin
    DatabaseCleaner.strategy = :truncation  # CHANGED FROM DEFAULT
  rescue NameError
    raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
  end

  # ADDED TO DEFAULT
  Capybara.save_and_open_page_path = '/tmp'
  Capybara.default_wait_time = 10

  require 'webmock/cucumber'
  WebMock.disable_net_connect! :allow_localhost => true

  require 'capybara/firebug'
  require 'factory_girl/step_definitions'
end

# this is similar to code in sunspot.rb
Sunspot.session = Sunspot.session.original_session
After do
  Sunspot.remove_all! 
end
at_exit do
  Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
end
