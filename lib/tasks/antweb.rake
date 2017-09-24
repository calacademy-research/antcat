namespace :antweb do
  desc "Export taxonomy"
  task export: :environment do
    Exporters::Antweb::Exporter[show_progress: true]
  end
end
