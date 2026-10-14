# frozen_string_literal: true

source 'https://rubygems.org'
ruby '4.0.7'

gem 'rails', '~> 8.1.4'

gem 'cssbundling-rails'
gem 'hamlit'
gem 'jsbundling-rails'
gem 'mysql2'
gem 'puma', '~> 8.0'
gem 'rack'
gem 'rack-cors'
gem 'rake'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'terser'

gem 'acts_as_list'
gem 'attr_extras'
gem 'aws-sdk-s3'
gem 'colorize'
gem 'config'
gem 'devise'
gem 'diffy'
gem 'draper'
gem 'ey_config' # Required for accessing service configurations through `EY::Config` on EngineYard.
gem 'grape-swagger-rails', '~> 0.7' # 1.x+ pulls in haml-rails alongside hamlit
gem 'gretel'
gem 'high_voltage'
gem 'inline_svg'
gem 'jquery-atwho-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 8.0'
gem 'ledermann-rails-settings'
# File type detection for uploaded reference PDFs (no longer loaded via Active Storage).
gem 'marcel'
gem 'newrelic_rpm'
gem 'nokogiri' # force_ruby_platform removed on antcat-prod so the precompiled gem is used
gem 'paper_trail', '~> 17.0'
# WARNING: Both this and ruby-progressbar define `ProgressBar`; this one is for `rake sunspot:solr:reindex`.
# progress_bar is hardcoded in sunspot_rails, and ruby-progressbar is a dependency of rubocop... hehe.
gem 'progress_bar', require: false
gem 'redcarpet'
gem 'request_store'
gem 'ruby-progressbar'
gem 'stimulus-rails'
gem 'strip_attributes'
gem 'sunspot_rails'
gem 'turbo-rails'
gem 'unread'
gem 'view_component'
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
  gem 'guard-shell'
  gem 'haml_lint', require: false
  gem 'pry'
  gem 'rspec-rails'
  gem 'rubocop', '~> 1.74', require: false
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
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'cuprite'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

# Uncomment for profiling.
# For production/staging envs, add `before_action { Rack::MiniProfiler.authorize_request }` to `ApplicationController`.
# gem 'rack-mini-profiler'
