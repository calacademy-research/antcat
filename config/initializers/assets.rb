# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w[*.svg *.eot *.woff *.ttf *.gif *.png *.ico]
Rails.application.config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif *.ico]

Rails.application.config.assets.precompile += %w[*.js]

Rails.application.config.assets.precompile += %w[foundation_and_overrides.css]
Rails.application.config.assets.precompile += %w[dev_css.css test_css.css]
Rails.application.config.assets.precompile += %w[jquery_overrides.css]
Rails.application.config.assets.precompile += %w[catalog_only.css]

Rails.application.config.assets.precompile += %w[site/*.css]
Rails.application.config.assets.precompile += %w[widgets/*.css]
Rails.application.config.assets.precompile += %w[controllers/*.css]
Rails.application.config.assets.precompile += %w[diffy.css]
