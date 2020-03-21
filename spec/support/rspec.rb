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
  # config.profile_examples = 10 # Uncomment to show slow specs.

  config.define_derived_metadata do |metadata|
    metadata[:aggregate_failures] = true
  end

  config.before(:each, :skip_ci) do |_example|
    if ENV["TRAVIS"]
      message = "spec disabled on Travis CI"
      $stdout.puts message.red
      skip message
    end
  end

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options.
  config.example_status_persistence_file_path = "spec/examples.txt"

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include JsonResponseHelper, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include FactoryBot::Syntax::Methods # To avoid typing `FactoryBot.create`.

  RSpec::Matchers.define_negated_matcher :not_change, :change
end
