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

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
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

Capybara.app = Rack::ShowExceptions.new(AntCat::Application)

include Warden::Test::Helpers
Warden.test_mode!

Warden::Manager.serialize_into_session do |user|
  user.email
end

Warden::Manager.serialize_from_session do |email|
  User.find_by_email email
end
