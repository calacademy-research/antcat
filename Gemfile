source 'http://rubygems.org'
ruby '2.1.10'

gem 'rails', '~> 4.2'

gem 'citrus', '2.4.1'
gem 'coffee-rails'
gem 'diff-lcs'
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
gem 'best_in_place', github: 'bernat/best_in_place'
gem 'colorize'
gem 'devise'
gem 'devise_invitable'
gem 'draper'
gem 'font-awesome-rails'
gem 'foundation-rails'
gem 'fuzzy-string-match'
gem 'gretel'
gem 'high_voltage'
gem 'invisible_captcha'
gem 'jquery-rails', '> 4.0'
gem 'jquery-ui-rails', '> 5.0'
gem 'paper_trail', git: "https://github.com/airblade/paper_trail.git", tag: 'v4.0.0.beta2'
gem 'paperclip'
gem 'redcarpet'
gem 'rouge'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'unread'
gem 'twitter-typeahead-rails'
gem 'will_paginate'
gem 'workflow'

# Support deprecated
gem 'protected_attributes' # attr_accesssible deprecated in rails 4.
gem 'rails-observers' # observers deprecated in rails 4

# Production
# TODO create :production group?
gem 'aws-sdk', '< 2.0'
# Version locked because of bug when fetching s3 hosted PDF:
#   uninitialized constant Paperclip::Storage::S3::AWS
#   test with: http://antcat.org/documents/6308/ward_2014_annu_rev_ecol_evol_syst_phylogeny_and_evolution_of_ants.pdf
gem 'ey_config'

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
