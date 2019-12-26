require_relative 'boot'

require 'rails/all'
require 'action_view/component'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AntCat
  # TODO: Very primitive feature toggling.
  # Added to make is easier to disable 'Fix Random!' in case of performance issues.
  SHOW_SOFT_VALIDATION_WARNINGS_IN_CATALOG = true

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = { arguments: '-i' }
    config.active_record.observers = [
      :reference_document_observer,
      :reference_observer
    ]

    config.eager_load_paths += Dir["#{config.root}/lib/**/"]
    config.eager_load_paths += Dir["#{config.root}/lib/tasks/**"]
    config.eager_load_paths += Dir["#{config.root}/app/models/**/*"]
    config.eager_load_paths += Dir["#{config.root}/app/models/database_scripts/database_scripts/**/*"]
    config.eager_load_paths += Dir["#{config.root}/app/decorators/**/"]
    config.eager_load_paths += Dir["#{config.root}/app/presenters/**/"]
    config.eager_load_paths += Dir["#{config.root}/app/services/**/"]

    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/tasks/**"]
    config.autoload_paths += Dir["#{config.root}/app/models/**/*"]
    config.autoload_paths += Dir["#{config.root}/app/models/database_scripts/database_scripts/**/*"]
    config.autoload_paths += Dir["#{config.root}/app/decorators/**/"]
    config.autoload_paths += Dir["#{config.root}/app/presenters/**/"]
    config.autoload_paths += Dir["#{config.root}/app/services/**/"]

    config.action_dispatch.cookies_serializer = :hybrid

    config.assets.enabled = true
  end
end

ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
