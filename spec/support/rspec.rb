# frozen_string_literal: true

require 'strip_attributes/matchers'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.expose_dsl_globally = true # Restore to default, see `config/initializers/irb.rb`.
  config.order = :random # Run `rspec --seed 1234` for debugging order dependency.
  config.fail_fast = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.filter_run_when_matching :focus unless ENV['CI']
  config.use_transactional_fixtures = true
  config.render_views
  Kernel.srand config.seed

  if ENV['PROFILE_EXAMPLES']
    config.profile_examples = 10
  end

  # Became an issue after adding mailer specs.
  # See https://github.com/drapergem/draper#view-context-leakage
  config.before { Draper::ViewContext.clear! }

  if ENV['AGGREGATE_FAILURES']
    config.define_derived_metadata do |metadata|
      metadata[:aggregate_failures] = true
    end
  end

  if ENV["CI"]
    config.before(:each, :skip_ci) do |_example|
      message = "spec disabled on CI"
      $stdout.puts message.red
      skip message
    end
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :deletion
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Login as controller helpers.
  config.before(:each, :as, type: :controller) do |example|
    as = example.metadata[:as]

    case as
    when :current_user
      sign_in current_user
    when :visitor
      nil # No-op.
    when :user, :helper, :editor, :superadmin, :developer
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

  # TODO: DRY w.r.t. "Login as controller helpers".
  # Login as feature helpers.
  config.before(:each, :as, type: :feature) do |example|
    as = example.metadata[:as]

    case as
    when :current_user
      sign_in current_user
    when :visitor
      nil # No-op.
    when :user, :helper, :editor, :superadmin, :developer
      sign_in create(:user, as)
    else
      location = example.metadata[:example_group][:location]
      $stdout.puts "#{location} sign in `:as` meta tag not supported".red
    end
  end
  config.before(:each, type: :feature) do |example|
    as = example.metadata[:as]

    if as.nil?
      location = example.metadata[:example_group][:location]
      $stdout.puts "#{location} does not specify any sign in `:as` meta tag".red
    end
  end

  config.after do
    Config.reload!
  end

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options.
  config.example_status_persistence_file_path = "spec/examples.txt"

  config.include ActiveSupport::Testing::TimeHelpers
  config.include FactoryBot::Syntax::Methods # To avoid typing `FactoryBot.create`.
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include JsonResponseHelper, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include FeatureHelpers::All, type: :feature
  config.include StripAttributes::Matchers, type: :model

  RSpec::Matchers.define_negated_matcher :not_change, :change
  RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 9999
end
