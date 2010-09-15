RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  config.gem 'haml'
  config.gem 'nokogiri'
  config.gem 'will_paginate'
  config.gem 'devise', :version => "1.0.8"
  config.gem 'devise_invitable', :version => '0.2.3'
  config.gem 'acts_as_list'
end

ActionMailer::Base.delivery_method = :sendmail
