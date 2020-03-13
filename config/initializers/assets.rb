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

Rails.application.config.assets.precompile += %w[
  application.js
  logged_in_only.js
  markdown_and_friends.js
  check_name_conflicts.js
  compare_revisions.js
  google_analytics.js
  locality_autocompletion.js
  protonym_select.js
  reference_select.js
  sortable_tables.js
  taxon_select.js
  taxt_editor.js
  tooltips.js
  controllers/authors/merges.js
  controllers/catalog/search/authors_autocompletion.js
  controllers/feedback/show.js
  controllers/references/form.js
  controllers/taxa/form/locality_autocompletion.js
  controllers/taxa/move_items/select_checkboxes.js
  controllers/taxa/reorder_history_items.js
  controllers/taxa/reorder_reference_sections.js
]

Rails.application.config.assets.precompile += %w[foundation_and_overrides.css]
Rails.application.config.assets.precompile += %w[font_awesome_and_custom_icons.css]
Rails.application.config.assets.precompile += %w[dev_css.css test_css.css]
Rails.application.config.assets.precompile += %w[jquery_overrides.css]
Rails.application.config.assets.precompile += %w[catalog_only.css]

Rails.application.config.assets.precompile += %w[site/*.css]
Rails.application.config.assets.precompile += %w[widgets/*.css]
Rails.application.config.assets.precompile += %w[controllers/*.css]
Rails.application.config.assets.precompile += %w[diffy.css]
