require 'devise'
require 'sunspot_test/rspec'

ENV["RAILS_ENV"] ||= 'test'
require_relative '../config/environment'
require 'rspec/rails'

require 'paper_trail/frameworks/rspec'
require 'webmock/rspec'
WebMock.disable_net_connect! allow_localhost: true

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.fail_fast = false

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before :all do
    DeferredGarbageCollection.start
  end

  config.after :all do
    DeferredGarbageCollection.reconsider
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
  config.include Devise::TestHelpers, type: :controller

  # To avoid typing `FactoryGirl.create` all the time (use `create`).
  config.include FactoryGirl::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
