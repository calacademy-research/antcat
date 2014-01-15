# coding: UTF-8
desc "Export taxonomy list"
task taxon_list: :environment do
  Exporters::TaxonList::Exporter.new.export
end
