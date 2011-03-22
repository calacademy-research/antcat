RAILS_GEM_VERSION = '2.3.10' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  config.autoload_paths << "#{RAILS_ROOT}/lib/grammar"

  config.active_record.observers = :author_name_observer
end

ActionMailer::Base.delivery_method = :sendmail

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
"<span class=\"fieldWithErrors\">#{html_tag}</span>" }
