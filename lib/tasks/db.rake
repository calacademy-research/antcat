# frozen_string_literal: true

namespace :db do
  desc "Download and import latest db dump from EngineYard"
  task import_latest: [:environment]  do
    sh "RAILS_ENV=#{Rails.env} ./script/db_dump/import_latest"
  end

  desc "rake db:drop + db:create + db:import_latest"
  task import_latestd: [:environment] do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:import_latest"].invoke
  end
end
