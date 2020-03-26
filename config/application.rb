# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AntCat
  # TODO: Very primitive feature toggling.
  # Added to make is easier to disable 'Fix Random!' in case of performance issues.
  SHOW_FAILED_SOFT_VALIDATION_IN_CATALOG = true

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # TODO: See if we can fine-tune this.
    config.middleware.insert_before(0, Rack::Cors) do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

    config.active_record.belongs_to_required_by_default = false # TODO: See if we can change this.
    config.action_view.form_with_generates_remote_forms = false

    config.action_mailer.default_url_options = { host: "antcat.org" }
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = { arguments: '-i' }
    config.active_record.observers = [
      :reference_document_observer,
      :reference_observer
    ]

    # TODO: Models and decorators are explicitly added to the autoload and eager load
    # paths since STI models are organized in subdirs without proper modules. This is OK
    # for now, but we may want to revisit it once we have decreased the number of
    # subclasses (which was the original motive for this non-Railsy structure).
    config.eager_load_paths += Dir["#{config.root}/app/models/**/*"]
    config.eager_load_paths += Dir["#{config.root}/app/decorators/**/"]
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    config.autoload_paths += Dir["#{config.root}/app/models/**/*"]
    config.autoload_paths += Dir["#{config.root}/app/decorators/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.secret_key_base = Settings.rails.secret_key_base

    config.action_dispatch.cookies_serializer = :hybrid
    config.assets.enabled = true
  end
end

ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
