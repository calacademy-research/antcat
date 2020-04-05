# frozen_string_literal: true

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

require 'capybara/apparition'
require 'cucumber/rails'
require 'cucumber/formatter/progress'
require 'cucumber/rspec/doubles' # For `stub` and `stub_const`.

require 'capybara-screenshot/cucumber'
require 'email_spec/cucumber'
require 'webmock/cucumber'
require 'sunspot_test/cucumber'

Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(app, js_errors: false)
end

Capybara.javascript_driver = :apparition
Capybara.default_max_wait_time = 5
Capybara.default_selector = :css
Capybara.save_path = './tmp/capybara'
Capybara.app = Rack::ShowExceptions.new AntCat::Application
Capybara::Screenshot.prune_strategy = :keep_last_run

ActionController::Base.allow_rescue = false
DatabaseCleaner.strategy = :transaction
InvisibleCaptcha.timestamp_enabled = false
PaperTrail.enabled = false
WebMock.disable_net_connect!(allow_localhost: true)

# Warden is what Devise uses for authorization.
World Warden::Test::Helpers
Warden.test_mode!
Warden::Manager.serialize_into_session(&:email)
Warden::Manager.serialize_from_session { |email| User.find_by(email: email) }

World FactoryBot::Syntax::Methods # To avoid typing `FactoryBot.create`.
