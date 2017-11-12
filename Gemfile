source 'http://rubygems.org'
ruby '2.1.10'

gem 'rails', '~> 4.2'

gem 'citrus', '2.4.1'
gem 'coffee-rails'
gem 'haml-rails'
gem 'mysql2'
gem 'quiet_assets'
gem 'rack'
gem 'rack-cors', require: 'rack/cors'
gem 'rake', '< 11.0'
gem 'request_store'
gem 'sass-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'xml-simple'
gem 'yui-compressor'

gem 'activeadmin', '~> 1.0.0.pre2'
gem 'acts_as_commentable_with_threading'
gem 'acts_as_list'
gem 'colorize'
gem 'data_migrate'
gem 'devise'
gem 'diffy', require: false
gem 'draper'
gem 'font-awesome-rails'
gem 'foundation-rails'
gem 'fuzzy-string-match', require: false
gem 'gretel'
gem 'high_voltage'
gem 'invisible_captcha'
gem 'jquery-atwho-rails'
gem 'jquery-rails', '> 4.0'
gem 'jquery-ui-rails', '> 5.0'
gem 'paper_trail', '< 5.0'
gem 'paperclip'
gem 'ruby-progressbar'
gem 'redcarpet'
gem 'rouge'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'unread'
gem 'strip_attributes'
gem 'twitter-typeahead-rails'
gem 'will_paginate'
gem 'workflow'

# Support deprecated
gem 'rails-observers' # observers deprecated in rails 4

# Production
# TODO create :production group?
# Version locked because of bug when fetching s3 hosted PDF:
#   uninitialized constant Paperclip::Storage::S3::AWS
#   test with: http://antcat.org/documents/6308/ward_2014_annu_rev_ecol_evol_syst_phylogeny_and_evolution_of_ants.pdf
gem 'aws-sdk', '< 2.0'
gem 'ey_config'

group :development do
  gem 'brakeman'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'headless'
  gem 'launchy'
  gem 'rspec-core' # required for configuring RSpec from env.rb
  gem 'rspec-rails'
  gem 'sunspot_test'
  gem 'thin'
  gem 'pry'
end

group :test do
  gem 'capybara', '>= 2.2.0'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'selenium-webdriver', '>= 2.48' # works with firefox as of v34
  gem 'chromedriver-helper'
  gem 'shoulda-matchers'
  gem 'webmock'
end

#####################################################
# Profiling gems kept uncommented here because lazy.
# See notes in `config/environments/production.rb`.
# gem 'bullet'
#
# gem 'newrelic_rpm'
#
# gem 'rack-mini-profiler', require: false
# gem 'flamegraph' # for rmp, optional
# gem 'stackprof' # for rmp, optional
#####################################################
