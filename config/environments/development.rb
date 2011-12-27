# coding: UTF-8
AntCat::Application.configure do

  config.action_controller.perform_caching = false

  config.cache_classes = false
  config.whiny_nils = true
  config.consider_all_requests_local = true
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.action_dispatch.best_standards_support = :builtin
  config.action_mailer.default_url_options = { :host => 'antcat.local' }
end

