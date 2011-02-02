RAILS_GEM_VERSION = '2.3.10' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  config.gem 'haml',            :version => '3.0.25'
  config.gem 'nokogiri',        :version => '1.4.4'
  config.gem 'will_paginate',   :version => '2.3.15'
  config.gem 'devise',          :version => "1.0.8"
  config.gem 'devise_invitable',:version => '0.2.3'
  config.gem 'acts_as_list',    :version => '0.1.2'
  config.gem 'lll',             :version => '1.3.0'
  config.gem 'citrus',          :version => '2.3.4'
  config.gem 'sunspot',         :version => '1.1.0', :lib => 'sunspot'
  config.gem 'sunspot_rails',   :version => '1.1.0', :lib => 'sunspot/rails'
  config.gem 'paper_trail',     :version => '1.6.4'
  config.gem 'factory_girl',    :version => '1.3.2', :lib => false
  config.gem 'paperclip',       :version => '2.3.6'
  config.gem 'aws-s3',          :version => '0.6.2', :lib => 'aws/s3'
  config.gem 'webmock',         :version => '1.6.1' if ['test', 'cucumber'].include? RAILS_ENV

  config.load_paths << "#{RAILS_ROOT}/lib/grammar"

  config.active_record.observers = :author_name_observer
end

ActionMailer::Base.delivery_method = :sendmail

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
"<span class=\"fieldWithErrors\">#{html_tag}</span>" }
