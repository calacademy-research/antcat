# coding: UTF-8
AntCat::Application.configure do
  config.cache_classes                              = ENV['DRB'] != 'true'
  config.whiny_nils                                 = true
  config.consider_all_requests_local                = true
  config.action_controller.perform_caching          = false
  config.action_dispatch.show_exceptions            = true
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method              = :test
  config.active_support.deprecation                 = :stderr
  config.serve_static_assets                        = true
  config.static_cache_control                       = "public, max-age = 3600"
  config.assets.compile                             = true
  config.assets.compress                            = false
  config.assets.debug                               = false
  config.assets.digest                              = false

  config.active_record.mass_assigment_sanitizer :strict

  PaperTrail.enabled = false
end

require 'lll'
