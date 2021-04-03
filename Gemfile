# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.7.1'

gem 'rails', '6.1.3'

gem 'citrus'
gem 'coffee-rails'
gem 'hamlit'
gem 'mysql2'
gem 'puma', '< 5'
gem 'rack'
gem 'rack-cors'
gem 'rake'
gem 'request_store'
gem 'sassc-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'

gem 'acts_as_list'
gem 'attr_extras'
gem 'aws-sdk', '< 3.0' # Version locked, see https://github.com/thoughtbot/paperclip/issues/2484
gem 'colorize'
gem 'config'
gem 'devise'
gem 'diffy', require: false
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
gem 'paper_trail', '~> 11.0'
gem 'rails-observers'
gem 'redcarpet'
gem 'ruby-progressbar'
gem 'strip_attributes'
gem 'strong_migrations'
gem 'sunspot_rails'
gem 'sunspot_solr', '2.2.0'
gem 'twitter-typeahead-rails'
gem 'unread'
gem 'webpacker', '5.1.1'
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
  gem 'rubocop', '~> 1.11.0', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'sunspot_test'
end

group :test do
  gem 'apparition'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

# Uncomment for profiling.
# gem 'rack-mini-profiler'
