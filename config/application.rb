# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# TODO: Upgrade paper_trail and remove.
# See https://github.com/paper-trail-gem/paper_trail/blob/master/lib/paper_trail/compatibility.rb
ENV["PT_SILENCE_AR_COMPAT_WARNING"] = 'yes'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AntCat
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
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

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end

ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
