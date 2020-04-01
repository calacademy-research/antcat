# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AntCat
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.load_defaults 6.0

    # TODO: See if we can fine-tune this.
    config.middleware.insert_before(0, Rack::Cors) do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

    config.active_record.belongs_to_required_by_default = true
    config.action_view.form_with_generates_remote_forms = false

    config.action_mailer.default_url_options = { host: "antcat.org" }
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = { arguments: '-i' }
    config.active_record.observers = [
      :reference_document_observer,
      :reference_observer
    ]

    config.secret_key_base = Settings.rails.secret_key_base

    config.action_dispatch.cookies_serializer = :hybrid
    config.assets.enabled = true
    config.after_initialize do
      if Rails.env.development? || ENV['DEV_MONKEY_PATCHES'] # Disable with `NO_DEV_MONKEY_PATCHES=y rails c`
        require Rails.root.join('lib/dev_monkey_patches')
        DevMonkeyPatches.enable
      end
    end
  end
end

ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
