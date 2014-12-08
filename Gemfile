source 'http://rubygems.org'
ruby '1.9.3'
#ruby=ruby-1.9.3-p392

gem 'acts_as_list'
gem 'aws-sdk'
gem 'citrus'
# see https://github.com/cucumber/cucumber-rails/issues/187#issuecomment-4160160
gem 'cucumber-rails', require: false
gem 'curb',             require: 'curl'
gem 'devise'
gem 'devise_invitable'
gem 'diff-lcs'
gem 'ey_config'
gem 'factory_girl_rails'
gem 'haml'
gem 'high_voltage'
gem 'jquery-rails',     '2.1.3'
gem 'mysql2'
gem 'newrelic_rpm'
gem 'nokogiri'
gem 'paper_trail'
gem 'paper_trail_manager'
gem 'progress_bar'
gem 'rack'
gem 'rails',            '~> 3'
gem 'rake'
gem 'sass'
gem 'sunspot_rails'
gem 'paperclip'
gem 'will_paginate'
gem 'workflow'
gem 'xml-simple'

group :development, :test do
  gem 'debugger'
  gem 'engineyard'
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'spork'
  gem 'sunspot_solr'
  gem 'thin'
end

group :development do
  gem 'rails-erd'
  gem 'wirble'
end

group :test do
  # This webdriver works with firefox as of v34. If firefox popus up without a URL,
  # check the latest
  gem 'selenium-webdriver', '>= 2.44.0'
  gem 'capybara',       '1.1.2'
  gem 'cucumber-api-steps', require: false
  gem 'database_cleaner'
  gem 'webmock'
end

group :assets do
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'yui-compressor'
end
