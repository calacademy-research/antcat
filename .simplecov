# frozen_string_literal: true

SimpleCov.configure do
  load_profile "test_frameworks"

  add_group "API", "app/controllers/api"
  add_group "Controllers", %r{app/controllers/(?!api)}
  add_group "Decorators", "app/decorators"
  add_group "Exporters", "app/exporters"
  add_group "Forms", "app/forms"
  add_group "Helpers", "app/helpers"
  add_group "Injectable formatters", "app/injectable_formatters"
  add_group "Lib", "lib/"
  add_group "Models", "app/models"
  add_group "Presenters", "app/presenters"
  add_group "Queries", "app/queries"
  add_group "Services", "app/services"

  track_files "{app,lib}/**/*.rb"

  add_filter %r{^/config/}
  add_filter %r{^/db/}

  add_filter "/app/cleanup/"
  add_filter "/app/database_scripts/database_scripts/"

  # Dev code.
  add_filter "/lib/generators/database_script_generator.rb"
  add_filter "/lib/dev_monkey_patches.rb"
  add_filter "/lib/dev_monkey_patches/"
  add_filter "/app/helpers/dev_helper.rb"
  add_filter "/app/controllers/antweb_data_controller.rb"
end
