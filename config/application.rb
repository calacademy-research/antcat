# coding: UTF-8
require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module AntCat
  class Application < Rails::Application
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = {:arguments => '-i'}
    config.active_record.observers = :author_name_observer
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.encoding = "utf-8"
    config.time_zone = 'UTC'
  end
end
