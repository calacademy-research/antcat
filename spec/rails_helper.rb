# frozen_string_literal: true

require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'

require 'sunspot_test/rspec' # Tag blocks with `:search` to enable Sunspot. Commit with `Sunspot.commit`.
SunspotTest.solr_startup_timeout = 60 # default 15 s is sometimes too short on CI
require_relative '../config/environment'
require 'rspec/rails'
require 'paper_trail/frameworks/rspec' # Tag blocks with `:versioning` to enable PaperTrail.
require 'capybara/rspec'
require 'capybara/cuprite'
require 'capybara-screenshot/rspec'

abort "The Rails environment is running in production mode!" if Rails.env.production?

Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

Aws.config[:s3] = { stub_responses: true }

ActiveRecord::Migration.maintain_test_schema!
