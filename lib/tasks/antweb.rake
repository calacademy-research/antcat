# coding: UTF-8
namespace :antweb do

  desc "Export taxonomy"
  task :export => :environment do
    Exporters::Antweb::Exporter.new(true).export 'data/output'
  end

end
