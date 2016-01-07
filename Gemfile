source 'http://rubygems.org'
ruby '2.1.2'

gem 'acts_as_list'
# Version locked because of bug when fetching s3 hosted PDF:
# uninitialized constant Paperclip::Storage::S3::AWS
# test with: http://antcat.org/documents/6308/ward_2014_annu_rev_ecol_evol_syst_phylogeny_and_evolution_of_ants.pdf
gem 'aws-sdk', '< 2.0'
gem 'citrus', '2.4.1'
gem 'curb', require: 'curl'
gem 'devise'
gem 'devise_invitable'
gem 'diff-lcs'
gem 'ey_config'
#gem 'newrelic_rpm'
gem 'haml'
gem 'high_voltage'
# gem 'jquery-rails', '2.1.3'
# gem 'jquery-migrate-rails', '>= 1.2.1'
gem 'mysql2', '~> 0.3.18'
gem 'jquery-rails', '> 4.0'
gem 'jquery-ui-rails', '> 5.0'
gem 'nokogiri'
gem 'paper_trail', :git => "https://github.com/airblade/paper_trail.git", :tag => 'v4.0.0.beta2'
gem 'protected_attributes' #attr_accesssible deprecated in rails 4.
gem 'rails-observers' # observers deprecated in rails 4
gem 'rack'
gem 'rails', '>= 4.2'
gem 'rake'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'paperclip'
gem 'will_paginate'
gem 'workflow'
gem 'xml-simple'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'request_store'
gem 'fuzzy-string-match'
gem 'activeadmin', '~> 1.0.0.pre2'

group :development, :test do
  gem 'factory_girl_rails'
  #gem 'byebug'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'thin'
  #gem 'web-console', '~> 2.0'
  gem 'sunspot_test'
  gem 'headless'
end

group :development do
  gem 'rails-erd'
  gem 'wirble'
  # gem "intellij-coffee-script-debugger", :git => "git://github.com/JetBrains/intellij-coffee-script-debugger.git"
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'selenium-webdriver', '>= 2.48' # works with firefox as of v34
  gem 'capybara', '>= 2.2.0'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'shoulda-matchers'
end

gem 'coffee-rails'
#version locked to fix error that happens in test: features/references/journals.feature:18
# "uninitialized constant Haml::Filters::SassImporter"
gem 'sass-rails', '4.0.5'
gem 'compass-rails', '2.0.0'
gem 'compass-blueprint'

gem 'uglifier'
gem 'yui-compressor'
gem 'twitter-typeahead-rails'
gem 'draper'
gem 'best_in_place', github: 'bernat/best_in_place'
