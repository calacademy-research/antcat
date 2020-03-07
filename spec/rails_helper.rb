require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'

require 'sunspot_test/rspec' # Tag blocks with `:search` to enable Sunspot. Commit with `Sunspot.commit`.
require_relative '../config/environment'
require 'rspec/rails'
require 'paper_trail/frameworks/rspec'

abort "The Rails environment is running in production mode!" if Rails.env.production?

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

InvisibleCaptcha.timestamp_enabled = false
