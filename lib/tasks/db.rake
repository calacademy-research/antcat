# frozen_string_literal: true

if Rails.env.development?
  namespace :db do
    desc "Download and import latest db dump from EngineYard"
    task :import_latest do
      sh "RAILS_ENV=development ./script/db_dump/import_latest"
    end
    task il: :import_latest # Shortcut.

    desc "Like `rake db:import_latest`, but without PaperTrail versions to speed up the import"
    task :import_latest_quick do
      sh "RAILS_ENV=development SKIP_VERSIONS=y ./script/db_dump/import_latest"
    end
    task ilq: :import_latest_quick # Shortcut.
  end
end
