source 'https://rubygems.org'
ruby '2.3.3'

gem 'rails', '< 5.3'

gem 'citrus'
gem 'coffee-rails'
gem 'haml-rails'
gem 'mysql2'
gem 'rack'
gem 'rack-cors', require: 'rack/cors'
gem 'rake'
gem 'request_store'
gem 'sass-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'

gem 'acts_as_commentable_with_threading'
gem 'acts_as_list'
gem 'aws-sdk', '< 3.0' # Version locked, see https://github.com/thoughtbot/paperclip/issues/2484
gem 'bootsnap', require: false
gem 'colorize'
gem 'data_migrate'
gem 'devise'
gem 'diffy', require: false
gem 'draper'
gem 'ey_config' # Required access service configurations through `EY::Config` on EngineYard.
gem 'font-awesome-rails'
gem 'foundation-rails', '6.3.1.0'
gem 'fuzzy-string-match', require: false
gem 'gretel'
gem 'high_voltage'
gem 'invisible_captcha'
gem 'jquery-atwho-rails'
gem 'jquery-rails', '> 4.0'
gem 'jquery-ui-rails', '> 5.0'
gem 'newrelic_rpm'
gem 'paper_trail', '< 10.0'
gem 'paperclip', '5.3.0'
gem 'rails-observers'
gem 'redcarpet'
gem 'ruby-progressbar'
gem 'select2-rails'
gem 'strip_attributes'
gem 'sunspot_rails'
gem 'sunspot_solr', '2.2.0'
gem 'swagger_ui_engine'
gem 'twitter-typeahead-rails'
gem 'unread'
gem 'validation_scopes'
gem 'will_paginate'
gem 'workflow', '< 2'

group :development do
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'rubocop', '~> 0.66.0', require: false
  gem 'rubocop-rspec'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'headless'
  gem 'launchy'
  gem 'pry'
  gem 'puma'
  gem 'rspec-core' # Required for configuring RSpec from `env.rb`.
  gem 'rspec-rails'
  gem 'sunspot_test'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  # TODO: sourced to GitHub because `DEPRECATED: Capybara::Helpers::normalize_whitespace`.
  gem 'capybara-webkit', git: 'https://github.com/thoughtbot/capybara-webkit.git', ref: '77fdac424'
  gem 'chromedriver-helper'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver', '>= 2.48' # works with firefox as of v34
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

# Uncomment for profiling.
# gem 'rack-mini-profiler'
