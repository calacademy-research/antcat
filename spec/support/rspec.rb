RSpec::Expectations.configuration.warn_about_potential_false_positives = false

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random # Run `rspec --seed 1234` for debugging order dependency.
  config.fail_fast = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.filter_run_when_matching :focus unless ENV['TRAVIS']
  config.use_transactional_fixtures = true
  Kernel.srand config.seed
  # TODO enable? `config.disable_monkey_patching!`
  # TODO maybe add `config.render_views = true`.
  # config.profile_examples = 10 # Uncommen to show slow specs.

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options.
  config.example_status_persistence_file_path = "spec/examples.txt"

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

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.around :each, feed: true do |example|
    Feed.enabled = true
    example.run
    Feed.enabled = false
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods # To avoid typing `FactoryBot.create`.
end
