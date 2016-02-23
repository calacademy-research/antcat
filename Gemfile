source 'http://rubygems.org'
ruby '2.1.2'

gem 'rails', '~> 4.2'

gem 'citrus', '2.4.1'
gem 'coffee-rails'
gem 'diff-lcs'
gem 'haml'
gem 'mysql2', '~> 0.3.18'
gem 'nokogiri'
gem 'quiet_assets'
gem 'rack'
gem 'rake'
gem 'request_store'
gem 'sass-rails'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'uglifier'
gem 'xml-simple'
gem 'yui-compressor'

gem 'activeadmin', '~> 1.0.0.pre2'
gem 'acts_as_list'
gem 'best_in_place', github: 'bernat/best_in_place'
gem 'bootstrap', '~> 4.0.0.alpha3'
gem 'colorize'
gem 'devise'
gem 'devise_invitable'
gem 'draper'
gem 'font-awesome-rails'
gem 'foundation-rails'
gem 'gretel'
gem 'high_voltage'
gem 'jquery-rails', '> 4.0'
gem 'jquery-ui-rails', '> 5.0'
gem 'js_cookie_rails'
gem 'paper_trail', :git => "https://github.com/airblade/paper_trail.git", :tag => 'v4.0.0.beta2'
gem 'paperclip'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'twitter-typeahead-rails'
gem 'will_paginate'
gem 'workflow'

# HOL importer
gem 'curb', require: 'curl'
gem 'fuzzy-string-match'

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
  gem 'teaspoon-jasmine'
  gem 'jasmine-jquery-rails'
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
