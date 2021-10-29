# frozen_string_literal: true

namespace :db do
  desc "Download and import latest db dump from EngineYard"
  task import_latest: [:environment] do
    sh "RAILS_ENV=development ./script/db_dump/import_latest"
  end
  task il: :import_latest
end
