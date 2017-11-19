Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: 'antcat.org' }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address:              Rails.application.secrets.email_address,
      port:                 Rails.application.secrets.email_port,
      domain:               Rails.application.secrets.email_domain,
      user_name:            Rails.application.secrets.email_user_name,
      password:             Rails.application.secrets.email_password,
      authentication:       Rails.application.secrets.email_authentication,
      enable_starttls_auto: Rails.application.secrets.email_enable_starttls_auto }

=begin
            ___________         __
            \_   _____/__  ____/  |_____________
             |    __)_\  \/  /\   __\_  __ \__  \
             |        \>    <  |  |  |  | \// __ \_
            /_______  /__/\_ \ |__|  |__|  (____  /
        _________   \/      \/   __             \/  __
        \_   ___ \  ____   _____/  |_  ____   _____/  |_
        /    \  \/ /  _ \ /    \   __\/ __ \ /    \   __\
        \     \___(  <_> )   |  \  | \  ___/|   |  \  |
         \______  /\____/|___|  /__|  \___  >___|  /__|
                \/            \/          \/     \/

  #############################################################################
  # Simulate production locally for debugging/profiling
  #############################################################################

    Uncomment these lines:
=end
    # config.cache_classes = false
    # config.serve_static_files = true
    # config.assets.debug = false
    # config.log_level = :debug
    ## See log in console (or run `tail -f log/production.log`)
    # ActiveRecord::Base.logger = Logger.new STDOUT
=begin
    Precompile assets: `rake assets:precompile`
    (you may also want to `rake assets:clobber` if SHTF)

    Run server: `rails s -e production`

  #############################################################################
  # Profile using Rack MiniProfiler
  #############################################################################

    Uncomment gem(s) in `Gemfile`.

    Add this to `ApplicationController`:
      before_action do
        if current_user.try :is_superadmin? # <-- Tweak if used in prod.
          Rack::MiniProfiler.authorize_request
        end
      end

    Uncomment this (or add it to `config/initializers/rack_profiler.rb`):
=end
    # require 'rack-mini-profiler'
    # Rack::MiniProfilerRails.initialize! Rails.application
=begin
    Reload any page and look in the top left corner.

  #############################################################################
  # Find N+1 queries using Bullet
  #############################################################################

    Uncomment gem in `Gemfile`.

    Add to `Application` in `config/application.rb`:
      config.after_initialize do
        Bullet.enable = true
        Bullet.console = true # JavaScript console
        Bullet.add_footer = true
      end

    Reload any page and look if there's anything in the footer.

=end
end
