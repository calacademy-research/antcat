# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.0.1'

gem 'rails', '7.0.2.3'

gem 'coffee-rails'
gem 'hamlit'
gem 'mysql2'
gem 'puma', '< 5'
gem 'rack'
gem 'rack-cors'
gem 'rake'
gem 'sassc-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'webpacker', '5.1.1'

gem 'acts_as_list'
gem 'attr_extras'
gem 'aws-sdk', '< 3.0' # Version locked, see https://github.com/thoughtbot/paperclip/issues/2484
gem 'colorize'
gem 'config'
gem 'devise'
gem 'diffy'
gem 'draper'
gem 'ey_config' # Required for accessing service configurations through `EY::Config` on EngineYard.
gem 'foundation-rails', '6.6.2.0'
gem 'grape-swagger-rails'
gem 'gretel'
gem 'high_voltage'
gem 'jquery-atwho-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'ledermann-rails-settings'
gem 'newrelic_rpm'
gem 'paperclip', '5.3.0'
gem 'paper_trail', '~> 12.0'
gem 'redcarpet'
gem 'request_store'
gem 'ruby-progressbar'
gem 'strip_attributes'
# TODO: Using GitHub ref for Ruby 3 compatibility, see https://github.com/sunspot/sunspot/issues/1007
# version must be above at least https://rubygems.org/gems/sunspot_rails/versions/2.5.0
# Without it, `rake sunspot:reindex` fails with this error:
#   "ArgumentError: wrong number of arguments (given 1, expected 0) ... `find_in_batches'".
gem 'sunspot_rails', github: 'sunspot/sunspot', ref: 'f2f01a6278030d086e0efb141dceefdcca8932bd'
gem 'sunspot_solr', '2.2.0'
gem 'twitter-typeahead-rails'
gem 'unread'
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
  gem 'rubocop', '~> 1.27.0', require: false
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
  gem 'cucumber-rails', '> 2.4.0', require: false
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

# Uncomment for profiling.
# For production/staging envs, add `before_action { Rack::MiniProfiler.authorize_request }` to `ApplicationController`.
# gem 'rack-mini-profiler'
