# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

Rails.application.config.assets.precompile += %w(*.svg *.eot *.woff *.ttf *.gif *.png *.ico)
Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.ico)

Rails.application.config.assets.precompile += %w( *.js )

Rails.application.config.assets.precompile += %w( active_admin.css )
Rails.application.config.assets.precompile += %w( foundation_and_overrides.css )
Rails.application.config.assets.precompile += %w( bootstrap_custom.css )
Rails.application.config.assets.precompile += %w( dev_env.css )
Rails.application.config.assets.precompile += %w( jquery_overrides.css )

Rails.application.config.assets.precompile += %w( widgets/*.css )
Rails.application.config.assets.precompile += %w( controllers/*.css )
