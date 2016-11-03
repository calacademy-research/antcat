ENV["RAILS_ENV"] ||= "test"
require_relative '../../config/environment'

require 'factory_girl'

require 'cucumber/rails'
require 'cucumber/formatter/progress'
require 'cucumber/rspec/doubles'

require 'capybara-screenshot/cucumber'
require 'webmock/cucumber'
require 'sunspot_test/cucumber'

if ENV['HEADLESS'] == 'true'
  require 'headless'

  headless = Headless.new
  headless.start

  at_exit do
    headless.destroy
  end
end

# TODO some day: change to `c.syntax = [:expect]`.
# Very not important, but the should syntax is deprecated.
RSpec.configure do |config|
  config.expect_with :rspec do |config|
    config.syntax = [:should, :expect]
  end
end

Capybara.javascript_driver = :webkit
if ENV['DRIVER'] == 'selenium'
  print "Enabling selenium driver..."
  Capybara.javascript_driver = :selenium
end

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end

Capybara.default_max_wait_time = 5
Capybara.default_selector = :css
Capybara.save_and_open_page_path = './tmp/capybara'
Capybara::Screenshot.prune_strategy = :keep_last_run

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :transaction

WebMock.disable_net_connect! allow_localhost: true
WebMock.stub_request :put, 'https://antcat.s3.amazonaws.com/1/21105.pdf'

Capybara.app = Rack::ShowExceptions.new AntCat::Application

# Warden is what Devise uses for authorization.
include Warden::Test::Helpers
Warden.test_mode!
Warden::Manager.serialize_into_session { |user| user.email }
Warden::Manager.serialize_from_session { |email| User.find_by(email: email) }

Feed::Activity.enabled = false

# TODO as of version 2.1, Capybara defaults to finding only visible elements,
# 1) confirm that's the case. 2) remove "visible" from a lot of places.
