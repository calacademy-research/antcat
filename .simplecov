SimpleCov.configure do
  load_profile "test_frameworks"

  add_group "API", "app/controllers/api"
  add_group "Controllers", /app\/controllers\/(?!api)/
  add_group "Decorators", "app/decorators"
  add_group "Helpers", "app/helpers"
  add_group "Lib", "lib/"
  add_group "Models", "app/models"
  add_group "Services", "app/services"

  track_files "{app,lib}/**/*.rb"

  add_filter %r{^/config/}
  add_filter %r{^/db/}

  add_filter "/app/database_scripts/database_scripts/"

  # Dev code.
  add_filter "/lib/generators/database_script_generator.rb"
  add_filter "/lib/dev_monkey_patches.rb"
  add_filter "/lib/progress.rb"
  add_filter "/lib/dev_monkey_patches/"
  add_filter "/app/helpers/dev_helper.rb"
  add_filter "/app/services/references/cache/invalidate_all.rb"
  add_filter "/app/services/references/cache/regenerate_all.rb"
  add_filter "/app/controllers/widget_tests_controller.rb"
  add_filter "/app/controllers/beta_and_such_controller.rb"
end
