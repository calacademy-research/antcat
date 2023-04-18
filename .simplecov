# frozen_string_literal: true

SimpleCov.configure do
  load_profile "test_frameworks"

  add_group "API", "app/controllers/api"
  add_group "Components", "app/components"
  add_group "Controllers", %r{app/controllers/(?!api)}
  add_group "Decorators", "app/decorators"
  add_group "Forms", "app/forms"
  add_group "Helpers", "app/helpers"
  add_group "Formatters", "app/formatters"
  add_group "Lib", %r{lib/(?!tasks)}
  add_group "Mailers", "app/mailers"
  add_group "Models", "app/models"
  add_group "Operations", "app/operations"
  add_group "Policies", "app/policies"
  add_group "Presenters", "app/presenters"
  add_group "Queries", "app/queries"
  add_group "Rake tasks", "lib/tasks"
  add_group "Serializers", "app/serializers"
  add_group "Services", "app/services"
  add_group "Validators", "app/validators"

  track_files "{app,lib}/**/*.rb"

  add_filter %r{^/config/}
  add_filter %r{^/db/}

  add_filter "/app/cleanup/"
  add_filter "/app/database_scripts/database_scripts/"

  # Dev code.
  add_filter "/app/controllers/devs_controller.rb"
  add_filter "/app/helpers/dev_helper.rb"
  add_filter "/lib/dev_monkey_patches.rb"
  add_filter "/lib/dev_monkey_patches/"
  add_filter "/lib/generators/"
  add_filter "/lib/tasks/seed/"
end
