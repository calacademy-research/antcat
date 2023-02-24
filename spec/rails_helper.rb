# frozen_string_literal: true

require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'

require 'sunspot_test/rspec' # Tag blocks with `:search` to enable Sunspot. Commit with `Sunspot.commit`.
require_relative '../config/environment'
require 'rspec/rails'
require 'paper_trail/frameworks/rspec' # Tag blocks with `:versioning` to enable PaperTrail.
require 'capybara/rspec'
require 'capybara/apparition'
require 'capybara-screenshot/rspec'

abort "The Rails environment is running in production mode!" if Rails.env.production?

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Aws.config[:s3] = { stub_responses: true }

ActiveRecord::Migration.maintain_test_schema!
