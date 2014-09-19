# coding: UTF-8
AntCat::Application.configure do
  config.action_controller.perform_caching = false
  config.cache_classes = false
  config.whiny_nils = true
  config.consider_all_requests_local = true
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.action_dispatch.best_standards_support = :builtin
  config.action_mailer.default_url_options = {host: 'antcat.local'}

# This line added to aid debugging; recommended by PLeary
  config.logger = Logger.new(STDOUT)

  config.assets.compress = false
  config.assets.debug = true

  config.active_record.mass_assigment_sanitizer :strict
  config.active_record.auto_explain_threshold_in_seconds = 0.5
end

require 'lll'
