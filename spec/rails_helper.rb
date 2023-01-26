# frozen_string_literal: true

require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'

require 'sunspot_test/rspec' # Tag blocks with `:search` to enable Sunspot. Commit with `Sunspot.commit`.
require_relative '../config/environment'
require 'rspec/rails'
require 'paper_trail/frameworks/rspec'
require 'capybara/rspec'
require 'capybara/apparition'
require 'capybara-screenshot/rspec'

abort "The Rails environment is running in production mode!" if Rails.env.production?

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Aws.config[:s3] = { stub_responses: true }

ActiveRecord::Migration.maintain_test_schema!

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
Capybara::Screenshot.prune_strategy = :keep_last_run
