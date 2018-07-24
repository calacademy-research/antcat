namespace :antweb do
  desc "Export taxonomy"
  task export: :environment do
    Exporters::Antweb::Exporter['data/output/antcat.antweb.txt']
  end
end
