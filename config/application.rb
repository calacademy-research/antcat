# frozen_string_literal: true

require_relative "boot"

require "rails"
# Only the frameworks AntCat uses. Not loaded (so their routes such as /rails/active_storage/* and
# /cable are gone): Active Storage, Action Cable, Action Mailbox, Action Text.
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AntCat
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # 7.1 -> 8.1 (2026-10) needed no overrides; session/cookie settings are unchanged since 7.1.
    # Notable: YJIT on outside dev/test, `Regexp.timeout = 1` (s), path-relative redirects raise.
    config.load_defaults 8.1

    config.middleware.insert_before(0, Rack::Cors) do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

    config.secret_key_base = Settings.rails.secret_key_base

    # NOTE: Without this, for example `activity.parameters[:name]` from
    # 'app/views/activities/templates/_protonym.html.haml' raises
    # `Psych::DisallowedClass Tried to load unspecified class: Symbol`
    # See https://github.com/rails/rails/blob/7-0-stable/activerecord/CHANGELOG.md#rails-7031-july-12-2022
    # and also https://github.com/paper-trail-gem/paper_trail/blob/master/doc/pt_13_yaml_safe_load.md
    config.active_record.yaml_column_permitted_classes = [
      ActiveSupport::HashWithIndifferentAccess,
      ActiveSupport::SafeBuffer,
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone,
      Symbol,
      Time
    ]

    console do
      ARGV.push "-r", root.join("config/initializers/irb.rb")
    end

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
