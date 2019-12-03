# For finding slow and unused steps:
#   cucumber -f usage
#   cucumber -f stepdefs

if ENV["COVERAGE"]
  require 'simplecov'

  SimpleCov.command_name "cucumber"
  SimpleCov.start
end

ENV["RAILS_ENV"] ||= "test"
require_relative '../../config/environment'

require 'factory_bot'

require 'cucumber/rails'
require 'cucumber/formatter/progress'
require 'cucumber/rspec/doubles'

require 'capybara-screenshot/cucumber'
require 'webmock/cucumber'
require 'sunspot_test/cucumber'

if ENV['HEADLESS']
  require 'headless'

  headless = Headless.new
  headless.start

  at_exit do
    headless.destroy
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expect_with_config|
    expect_with_config.syntax = [:expect]
  end
end

# "webkit" is our default driver. It's headless.
def set_driver
  driver = ENV['DRIVER'] || "webkit"
  puts "Using driver: #{driver}.".blue
  case driver
  when "webkit"
    Capybara.javascript_driver = :webkit
  end
end

set_driver

Capybara::Webkit.configure(&:block_unknown_urls)

Capybara.default_max_wait_time = 5
Capybara.default_selector = :css
Capybara.save_path = './tmp/capybara'
Capybara::Screenshot.prune_strategy = :keep_last_run

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :transaction

WebMock.disable_net_connect! allow_localhost: true
WebMock.stub_request :put, 'https://antcat.s3.amazonaws.com/1/21105.pdf'

Capybara.app = Rack::ShowExceptions.new AntCat::Application

InvisibleCaptcha.timestamp_enabled = false

# Warden is what Devise uses for authorization.
World Warden::Test::Helpers
Warden.test_mode!
Warden::Manager.serialize_into_session(&:email)
Warden::Manager.serialize_from_session { |email| User.find_by(email: email) }

World FactoryBot::Syntax::Methods # To avoid typing `FactoryBot.create`.
