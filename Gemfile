# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.0.1'

gem 'rails', '7.0.4.2'

gem 'coffee-rails'
gem 'hamlit'
gem 'mysql2'
gem 'puma', '< 6'
gem 'rack'
gem 'rack-cors'
gem 'rake'
gem 'sassc-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'webpacker', '6.0.0.rc.6'

gem 'acts_as_list'
gem 'attr_extras'
gem 'aws-sdk-s3'
gem 'colorize'
gem 'config'
gem 'devise'
gem 'diffy'
gem 'draper'
gem 'ey_config' # Required for accessing service configurations through `EY::Config` on EngineYard.
gem 'grape-swagger-rails'
gem 'gretel'
gem 'high_voltage'
gem 'jquery-atwho-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'ledermann-rails-settings'
gem 'newrelic_rpm'
gem 'paperclip'
gem 'paper_trail', '~> 14.0'
# WARNING: Both this and ruby-progressbar define `ProgressBar`; this one is for `rake sunspot:solr:reindex`.
# progress_bar is hardcoded in sunspot_rails, and ruby-progressbar is a dependency of rubocop... hehe.
gem 'progress_bar', require: false
gem 'redcarpet'
gem 'request_store'
gem 'ruby-progressbar'
gem 'stimulus-rails'
gem 'strip_attributes'
gem 'sunspot_rails'
gem 'sunspot_solr', '2.2.0'
gem 'turbo-rails'
gem 'twitter-typeahead-rails'
gem 'unread'
gem 'view_component'
# NOTE: webrick is required for `ReferenceDocument#actual_url`, but specs may incorrectly pass even after removing
# webrick from here if it happens to be loaded as a dependency for gems in the :test group (for example cucumber-rails).
gem 'webrick'
gem 'will_paginate'

group :development do
  gem 'awesome_print', require: 'ap'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'rubycritic', '> 4', require: false
  gem 'tabulo'
end

group :development, :test do
  gem 'email_spec'
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'haml_lint', require: false
  gem 'pry'
  gem 'rspec-rails'
  gem 'rubocop', '~> 1.46.0', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'sunspot_test'
end

group :test do
  # TODO: To fix `Unexpected inner loop exception`, see https://github.com/twalpole/apparition/issues/81
  # version must be above at least https://rubygems.org/gems/apparition/versions/0.6.0
  gem 'apparition', github: 'twalpole/apparition', ref: 'ca86be4d54af835d531dbcd2b86e7b2c77f85f34'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

# Uncomment for profiling.
# For production/staging envs, add `before_action { Rack::MiniProfiler.authorize_request }` to `ApplicationController`.
# gem 'rack-mini-profiler'
