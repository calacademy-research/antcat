Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  #config.action_controller.action_on_unpermitted_parameters = :raise # prepare migration

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_dispatch.best_standards_support = :builtin
  config.action_mailer.default_url_options = {host: 'antcat.local'}

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  config.log_level = :info

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false

  config.action_mailer.smtp_settings = {
      address:              Rails.application.secrets.email_address,
      port:                 Rails.application.secrets.email_port,
      domain:               Rails.application.secrets.email_domain,
      user_name:            Rails.application.secrets.email_user_name,
      password:             Rails.application.secrets.email_password,
      authentication:       Rails.application.secrets.email_authentication,
      enable_starttls_auto: Rails.application.secrets.email_enable_starttls_auto  }
end