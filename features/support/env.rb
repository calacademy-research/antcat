# frozen_string_literal: true

# For finding slow and unused steps:
#   cucumber -f usage
#   cucumber -f stepdefs

require_relative './../coverage_cucumber'

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
  Capybara::Apparition::Driver.new(
    app,
    js_errors: false,
    browser_options: [
      :no_sandbox # For Docker, see https://stackoverflow.com/a/57508822.
    ]
  )
end

Capybara.javascript_driver = :apparition
Capybara.default_max_wait_time = 5
Capybara.default_selector = :css
Capybara.save_path = './tmp/capybara'
Capybara.app = Rack::ShowExceptions.new AntCat::Application
Capybara::Screenshot.prune_strategy = :keep_last_run

ActionController::Base.allow_rescue = false
DatabaseCleaner.strategy = :transaction
PaperTrail.enabled = false
WebMock.disable_net_connect!(allow_localhost: true)

# Warden is what Devise uses for authorization.
World Warden::Test::Helpers
Warden.test_mode!
Warden::Manager.serialize_into_session(&:email)
Warden::Manager.serialize_from_session { |email| User.find_by!(email: email) }

World FactoryBot::Syntax::Methods # To avoid typing `FactoryBot.create`.

require_relative './cucumber_helpers/selectors'
World CucumberHelpers::Selectors

require_relative './cucumber_helpers/within_helpers'
World CucumberHelpers::WithinHelpers

require_relative './cucumber_helpers/paths'
World CucumberHelpers::Paths
