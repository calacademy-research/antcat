# coding: UTF-8
AntCat::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.log_level = :debug
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.action_mailer.default_url_options = { :host => 'antcat.org' }
  config.serve_static_assets = false

  config.assets.compress = true
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :yui
  config.assets.compile = false

  config.assets.precompile = [->(path) {
    true
  }]

  config.assets.digest = true
end

require 'lll'
