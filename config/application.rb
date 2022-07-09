# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AntCat
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.middleware.insert_before(0, Rack::Cors) do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

    config.secret_key_base = Settings.rails.secret_key_base

    console do
      ARGV.push "-r", root.join("config/initializers/irb.rb")
    end

    config.after_initialize do
      if Rails.env.development? || ENV['DEV_MONKEY_PATCHES'] # Disable with `NO_DEV_MONKEY_PATCHES=y rails c`
        require Rails.root.join('lib/dev_monkey_patches')
        DevMonkeyPatches.enable
      end
    end

    # Don't precompile Turbo assets because they break the JS uglifier, see
    # https://github.com/hotwired/turbo-rails/blob/3355f2fae0a2bd3653ccccc62d9395b677c4ee1f/lib/turbo/engine.rb#L23
    # To reproduce in dev/test: `config.assets.js_compressor = Uglifier.new(harmony: true)`.
    config.after_initialize do
      config.assets.precompile -= Turbo::Engine::PRECOMPILE_ASSETS
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
