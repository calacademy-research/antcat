require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AntCat
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    #config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = { arguments: '-i' }
    config.active_record.observers = [
      :author_name_observer,
      :journal_observer,
      :place_observer,
      :publisher_observer,
      :reference_author_name_observer,
      :reference_document_observer,
      :reference_observer,
    ]

    config.enable_dependency_loading = true

    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/tasks/**"]
    config.autoload_paths += Dir["#{config.root}/app/models/**/"]
    config.autoload_paths += Dir["#{config.root}/app/decorators/**/"]
    config.autoload_paths += Dir["#{config.root}/app/services/**/"]

    config.action_dispatch.cookies_serializer = :hybrid

    config.assets.enabled = true
  end
end

ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
