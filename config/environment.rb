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
  config.gem 'lll'
  config.gem 'citrus', :version => '2.2.2'
  config.gem 'sunspot', :lib => 'sunspot'
  config.gem 'sunspot_rails', :lib => 'sunspot/rails'
  config.gem 'paper_trail'
  config.gem 'factory_girl', :lib => false
  config.gem 'paperclip'
  config.gem 'aws-s3', :lib => 'aws/s3'

  config.gem 'webmock' if ['test', 'cucumber'].include? RAILS_ENV

  config.load_paths << "#{RAILS_ROOT}/lib/grammar"
end

ActionMailer::Base.delivery_method = :sendmail

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
"<span class=\"fieldWithErrors\">#{html_tag}</span>" }
