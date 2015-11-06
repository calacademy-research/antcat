# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

#TODO: Probably not the right way to do any of this. Bootstrapping rails 4.
Rails.application.config.assets.precompile += %w( widgets/*.js )
Rails.application.config.assets.precompile += %w( widgets/*.coffee )
# Rails.application.config.assets.precompile += %w( *.js )

Rails.application.config.assets.precompile += %w(*.svg *.eot *.woff *.ttf *.gif *.png *.ico)
Rails.application.config.assets.precompile << /\A(?!active_admin).*\.(js|css)\z/
Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.ico)
#TODO: Swtich to gem-ified version of jquery-ui
# Rails.application.config.assets.precompile += %w( ext/jquery.ui.custom.css )
# Rails.application.config.assets.precompile += %w( jquery.ui.custom.custom.css )

# Rails.application.config.assets.precompile += %w( *.css )


