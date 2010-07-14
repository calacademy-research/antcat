RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  config.gem 'erector'
  config.gem 'haml' # for Sass
  config.gem 'less'
  config.gem 'will_paginate'
end

require 'erector'
