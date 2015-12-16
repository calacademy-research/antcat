require File.expand_path('../boot', __FILE__)

require 'rails/all'

#
# This block is a duplicate of the paper_trail.rb initializer.
# There is an intermittent (!) loading order issue where we're seeing
# change_id being flagged as not writable. Putting this block here
# seems to have fixed it; remove this block if/when we move beyond 4.0 beta 2 and see
# if deleting and undoing a delete still causes the problem. Do at least three tests.
#
# Note: This should probably be require 'config/initializers/paper_trail.rb',
# but because this is intermittent I'm not changing anything until I know this is the fix.
#
require 'protected_attributes'

module PaperTrail
  class Version < ::ActiveRecord::Base
    attr_accessible :change_id
  end
end
#
#  End of stupid
#

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AntCat
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = {:arguments => '-i'}
    config.active_record.observers = [
        :author_name_observer,
        :journal_observer,
        :place_observer,
        :publisher_observer,
        :reference_author_name_observer,
        :reference_document_observer,
        :reference_observer,
    ]

    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir["#{config.root}/app/models/**/"]
    config.autoload_paths += Dir["#{config.root}/app/decorators/**/"]

    config.action_dispatch.cookies_serializer = :hybrid
    # suppress deprecation warning
    config.active_record.raise_in_transactional_callbacks = true
    config.assets.enabled = true
    #
    # We were not reloading /lib properly (despite the above "autoload paths" invocation.)
    # This voodoo does it.
    #
    config.eager_load_paths += ["#{Rails.root}/lib}"]
  end
end

ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
