source 'http://rubygems.org'
ruby '2.1.2'

gem 'acts_as_list'
gem 'aws-sdk'
gem 'citrus', '2.4.1'
# see https://github.com/cucumber/cucumber-rails/issues/187#issuecomment-4160160
# shouldn't this be in test only? todo: move this and try it
gem 'cucumber-rails', require: false
gem 'curb', require: 'curl'
gem 'devise'
gem 'devise_invitable'
gem 'diff-lcs'
gem 'ey_config'
gem 'factory_girl_rails'
gem 'haml'
gem 'high_voltage'
gem 'jquery-rails', '2.1.3'
# Todo: Switch to a gem-ified version of jquery-ui
#gem 'jquery-ui-rails'
gem 'mysql2'
#gem 'newrelic_rpm'
gem 'nokogiri'
gem 'paper_trail', :git => "https://github.com/airblade/paper_trail.git", :tag => 'v4.0.0.beta2'
gem 'protected_attributes' #attr_accesssible deprecated in rails 4.
gem 'rails-observers' # observers deprecated in rails 4
gem 'rack'
gem 'rails', '>= 4.1'
gem 'rake'
gem 'sunspot_rails'
gem 'sunspot_solr'

gem 'paperclip'
gem 'will_paginate'
gem 'workflow'
gem 'xml-simple'
gem 'sprockets-rails', :require => 'sprockets/railtie'


group :development, :test do
  gem 'byebug'
  #gem 'engineyard'
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'spork'
  gem 'thin'
  #gem 'web-console', '~> 2.0'
end

group :development do
  gem 'rails-erd'
  gem 'wirble'
  # gem "intellij-coffee-script-debugger", :git => "git://github.com/JetBrains/intellij-coffee-script-debugger.git"
end

group :test do
  # This webdriver works with firefox as of v34. If firefox popus up without a URL,
  # check the latest
  gem 'selenium-webdriver', '>= 2.44.0'
  gem 'capybara', '>= 2.2.0'
  gem 'cucumber-api-steps', require: false
  gem 'database_cleaner'
  gem 'webmock'
end

gem 'coffee-rails'
#version locked to fix error that happens in test: features/references/journals.feature:18
# "uninitialized constant Haml::Filters::SassImporter"
gem 'sass-rails', '4.0.5'
gem 'compass-rails', '2.0.0'
gem 'compass-blueprint'

gem 'uglifier'
gem 'yui-compressor'



