# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.2.1'

gem 'rails', '7.0.4.3'

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
# TODO: This can be removed after upgrading to Rails 7.1, see https://stackoverflow.com/a/79361034
gem 'concurrent-ruby', '1.3.4'
gem 'config'
gem 'devise'
gem 'diffy'
gem 'draper'
gem 'ey_config' # Required for accessing service configurations through `EY::Config` on EngineYard.
gem 'grape-swagger-rails'
gem 'gretel'
gem 'high_voltage'
gem 'inline_svg'
gem 'jquery-atwho-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'ledermann-rails-settings'
gem 'newrelic_rpm'
gem 'nokogiri', force_ruby_platform: true
gem 'paperclip'
gem 'paper_trail', '~> 16.0'
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
# TODO: Upgrade guide: https://github.com/rails/tailwindcss-rails/blob/main/README.md#upgrading-your-application-from-tailwind-v3-to-v4
gem 'tailwindcss-rails', '< 4'
gem 'turbo-rails'
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
  # TODO: Pinned to GitHub to fix dependency issue:
  # Bundler could not find compatible versions for gem "parser":
  #   In Gemfile:
  #     rubycritic (> 4) was resolved to 4.9.1, which depends on
  #       reek (~> 6.0, < 6.2) was resolved to 6.1.4, which depends on
  #         parser (~> 3.2.0)
  #
  #     rubocop (~> 1.61.0) was resolved to 1.61.0, which depends on
  #       parser (>= 3.3.0.2)
  gem 'rubycritic', '> 4', require: false, github: 'whitesmith/rubycritic', ref: '27445832495742d45ee10b5a80ff33b0d86cd26d'
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
  gem 'rubocop', '~> 1.69.1', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails', require: false
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
