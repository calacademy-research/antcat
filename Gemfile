source 'http://rubygems.org'
ruby '2.3.3'

gem 'rails', '~> 4.2'

gem 'citrus', '2.4.1'
gem 'coffee-rails'
gem 'haml-rails'
gem 'mysql2'
gem 'quiet_assets'
gem 'rack'
gem 'rack-cors', require: 'rack/cors'
gem 'rake'
gem 'request_store'
gem 'sass-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'xml-simple'
gem 'yui-compressor'

gem 'activeadmin'
gem 'acts_as_commentable_with_threading'
gem 'acts_as_list'
gem 'aws-sdk', '< 2.0'
# Version locked because of bug when fetching s3 hosted PDF:
#   `uninitialized constant Paperclip::Storage::S3::AWS`
#   Test with: http://antcat.org/documents/6308/ward_2014_annu_rev_ecol_evol_syst_phylogeny_and_evolution_of_ants.pdf
gem 'colorize'
gem 'data_migrate'
gem 'devise'
gem 'diffy', require: false
gem 'draper'
gem 'ey_config'
gem 'font-awesome-rails'
gem 'foundation-rails'
gem 'fuzzy-string-match', require: false
gem 'gretel'
gem 'high_voltage'
gem 'invisible_captcha'
gem 'jquery-atwho-rails'
gem 'jquery-rails', '> 4.0'
gem 'jquery-ui-rails', '> 5.0'
gem 'newrelic_rpm'
gem 'paper_trail', '< 8.0'
gem 'paperclip'
gem 'rails-observers'
gem 'redcarpet'
gem 'rouge'
gem 'ruby-progressbar'
gem 'select2-rails'
gem 'strip_attributes'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'twitter-typeahead-rails'
gem 'unread'
gem 'will_paginate'
gem 'workflow'

group :development do
  gem 'brakeman'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'headless'
  gem 'launchy'
  gem 'pry'
  gem 'rspec-core' # Required for configuring RSpec from `env.rb`.
  gem 'rspec-rails'
  gem 'sunspot_test'
  gem 'thin'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
  gem 'chromedriver-helper'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'selenium-webdriver', '>= 2.48' # works with firefox as of v34
  gem 'shoulda-matchers'
  gem 'webmock'
end

#####################################################
# Profiling gems kept uncommented here because lazy.
# See notes in `config/environments/production.rb`.
# gem 'bullet'
# gem 'rack-mini-profiler', require: false
# gem 'flamegraph' # for rmp, optional
# gem 'stackprof' # for rmp, optional
#####################################################
