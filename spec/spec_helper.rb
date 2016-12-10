ENV["RAILS_ENV"] ||= 'test'

# Tag blocks with `search: true` to enable Sunspot. Commit with `Sunspot.commit`.
require 'sunspot_test/rspec'
require_relative '../config/environment'
require 'rspec/rails'
require 'paper_trail/frameworks/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Feed.enabled = false

# TODO extra curricular: split this and support files into spec_helper/rails_helper.
