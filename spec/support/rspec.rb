# frozen_string_literal: true

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

  if ENV['PROFILE_EXAMPLES']
    config.profile_examples = 10
  end

  # Became an issue after adding mailer specs.
  # See https://github.com/drapergem/draper#view-context-leakage
  config.before { Draper::ViewContext.clear! }

  config.define_derived_metadata do |metadata|
    metadata[:aggregate_failures] = true
  end

  if ENV["TRAVIS"]
    config.before(:each, :skip_ci) do |_example|
      message = "spec disabled on Travis CI"
      $stdout.puts message.red
      skip message
    end
  end

  config.before(:each, :as, type: :controller) do |example|
    as = example.metadata[:as]

    case as
    when :current_user
      sign_in current_user
    when :visitor
      nil # No-op.
    when :user, :helper, :editor, :superadmin
      sign_in create(:user, as)
    else
      location = example.metadata[:example_group][:location]
      $stdout.puts "#{location} sign in `:as` meta tag not supported".red
    end
  end

  config.before(:each, type: :controller) do |example|
    as = example.metadata[:as]

    if as.nil?
      location = example.metadata[:example_group][:location]
      $stdout.puts "#{location} does not specify any sign in `:as` meta tag".red
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
