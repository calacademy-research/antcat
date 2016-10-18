namespace :antweb do

  desc "Export taxonomy"
  task export: :environment do
    Exporters::Antweb::Exporter.new(true).export 'data/output'
  end

  desc "Export debug - single taxon"
  task :export_one, [:taxon_id] => :environment do |t, args|
    taxon_id = args[:taxon_id] || 459601
    Exporters::Antweb::Exporter.new(true).export_one taxon_id
  end

end
