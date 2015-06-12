# coding: UTF-8
namespace :antweb do

  desc "Export taxonomy"
  task :export => :environment do
    Exporters::Antweb::Exporter.new(true).export 'data/output'
  end

  desc "Export debug - single taxon"
  task :export_one => :environment do
    Exporters::Antweb::Exporter.new(true).export_one 486707
  end

end
