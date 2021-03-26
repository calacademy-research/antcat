# frozen_string_literal: true

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
  jquery-ui/core.js
  jquery-ui/widgets/autocomplete.js
  jquery-ui/widgets/draggable.js
  jquery-ui/widgets/sortable.js

  application.js
  logged_in_only.js
  markdown_and_friends.js

  check_name_conflicts.js
  highlight_text.js
  jquery3.js
  locality_autocompletion.js
  reorder_items.js
  revision_comparer.js
  sortable_tables.js
  taxt_editor.js

  controllers/activities/scroll_to_highlighted_activity.js
  controllers/authors/merges.js
  controllers/catalog/search/authors_autocompletion.js
  controllers/feedbacks/show.js
  controllers/references/form.js
  controllers/taxa/copy_name_to_protonym.js
  controllers/taxa/move_items/select_checkboxes.js

  globals/create_copy_buttons.js

  logged_in_only/history_item_form
]

Rails.application.config.assets.precompile += %w[
  diffy.css
  font_awesome_and_custom_icons.css
  foundation_and_overrides.css
  logged_in_only.css
  vendor.css
  vue.css

  controllers/*.css
  env_specific/*.css
  site/*.css
  widgets/*.css
]
